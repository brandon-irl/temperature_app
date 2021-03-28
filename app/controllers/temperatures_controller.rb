require 'net/http'
require 'json'

# Example call: http://example.com/temperatures?q[]=London&q[]=Dublin&q[]=New%20York%20City&q[]=Moscow&q[]=Beijing&q[]=Shanghai&q[]=Cairo&q[]=Barcelona&q[]=Madrid&q[]=Lisbon&appid=4V8HB31TYB6WE2I5SYSEHMOK3AEXYCFW&units=imperial
class TemperaturesController < ApplicationController
  FIXNUM_MAX = (2**(0.size * 8 - 2) - 1)
  FIXNUM_MIN = -(2**(0.size * 8 - 2))
  UNITS = %w[metric imperial].freeze
  APPID_LENGTH = 32

  def validate_params
    params.require(%i[q appid])
    raise 'Too many cities' if params[:q].length > 10
    raise 'cities must be an array' unless params[:q].respond_to?(:join)
    raise 'appid is invalid' if params[:appid].length != 32
  end

  def sanitize_params
    params[:q] = params[:q].uniq
    unless UNITS.include? params[:units]
      puts "invalid units '#{params[:units]}'"
      params[:units] = UNITS[0]
    end
  end

  def fetch_temperatures(city, appid, units)
    Rails.cache.fetch(city + params[:units], expires_in: 1.minutes) do
      # make API call
      res = Net::HTTP.get_response('api.openweathermap.org',
                                   "/data/2.5/weather?q=#{city}&units=#{units}&appid=#{appid}")
      case res.code
      when '200'
        JSON.parse(res.body)['main']
      else
        JSON.parse(res.body)
      end
    end
  end

  def show
    begin
      validate_params
      sanitize_params
    rescue StandardError => e
      render json: { code: 400, message: e }, status: :bad_request and return
    end

    begin
      result = Rails.cache.fetch(params[:appid] + params[:q].join(',') + params[:units], expires_in: 5.minutes) do
        hash = { cities: [], highest: [], lowest: [] }
        high_temp = FIXNUM_MIN
        low_temp =  FIXNUM_MAX
        params[:q].each do |city|
          main = fetch_temperatures(city, params[:appid], params[:units])
          # set cities property
          hash[:cities].push({ name: city, temperatures: main })
          next if main['temp'].nil?

          # set highest
          if hash[:highest].nil? || main['temp'] > high_temp
            high_temp = main['temp']
            hash[:highest] = [city]
          elsif main['temp'] == high_temp
            hash[:highest].push(city)
          end
          # set lowest
          if hash[:lowest].nil? || main['temp'] < low_temp
            low_temp = main['temp']
            hash[:lowest] = [city]
          elsif main['temp'] == low_temp
            hash[:lowest].push(city)
          end
        end
        hash
      end
      render json: result
    rescue StandardError => e
      render json: { message: 'An unexpected error occurred. Please try again later.', detail: e }
    end
  end
end
