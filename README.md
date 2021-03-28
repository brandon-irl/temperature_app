# Temperature App

## Overview
This is an application that provides temperature information for a multitude of cities. It is written in Ruby 3.0.0 on Rails 6.1.3.1. It depends on PostgreSQL (12.6) in order to be hosted on Heroku.

To see a live version of this app, [click here](https://young-escarpment-01111.herokuapp.com/).

This app uses [Open Weather Map](https://openweathermap.org/) to source temperature data.

## Usage
### GET current temperature data for one or multiple locations

> ht<span>tps://young-escarpment-01111.herokuapp.com/temperatures?q[]=</span><span style="color:orange">{city name}</span>&q[]=<span style="color:orange">{second city name}</span>&appid=<span style="color:orange">{API key}</span>&units=<span style="color:orange">imperial</span>

You can also reach this endpoint on the root domain
> ht<span>tps://young-escarpment-01111.herokuapp.com?q[]=</span><span style="color:orange">{city name}</span>&q[]=<span style="color:orange">{second city name}</span>&appid=<span style="color:orange">{API key}</span>&units=<span style="color:orange">imperial</span>
### Parameters
parameter||type|example|description
---|---|---|---| ---
`q`|*required*|array|new%20york%20city|One or more city names
`appid`|*required*|string| | Your unique API key from openweathermap.org. Must be 32 characters long.
`units`|*optional*|string|<ul><li>imperial</li><li>metric</li></ul>|`imperial` for Farenheit, `metric` for Celcius. If absent, `metric` will be used by default.

### Notes
Queries are cached using the parameters as key and expire after 5 minutes. Individual city values are also cached and expire after 1 min.

## Credits
>[brandon alexander](http://brandonalexander.dev)