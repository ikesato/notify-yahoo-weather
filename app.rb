# -*- coding: utf-8 -*-
require 'sinatra'
require 'eventmachine'
require 'slack-notifier'
require './yolp-weather'
require 'pp'

weather = YolWeather.new(appid: "dj0zaiZpPTZpTUZRUzI3MmN4WiZzPWNvbnN1bWVyc2VjcmV0Jng9ZDI")
weather.location = {lat: 35.649657, lng: 139.752162}
weather.sync

notifier = Slack::Notifier.new "https://hooks.slack.com/services/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"
notifier.ping "Bot started"

counter = 1
EM::defer do
  loop do
    sleep 10*60
    counter += 1
    weather.sync
    notifier.ping notification_messages
  end
end

get '/hello' do
  "world #{counter}"
end

get '/debug/now' do
  Time.now.to_s
end

get '/debug/weather' do
  content_type 'text/plain'
  PP.pp(weather.weather, '')
end

get '/debug/notifications' do
  content_type 'text/plain'
  PP.pp(weather.notifications, '')
end

get '/debug/counter' do
  counter.to_s
end
