# -*- coding: utf-8 -*-
require 'sinatra'
require 'eventmachine'
require 'slack-notifier'
require 'open-uri'
require './yolp-weather'
require 'pp'

weather = YolpWeather.new(appid: "dj0zaiZpPTZpTUZRUzI3MmN4WiZzPWNvbnN1bWVyc2VjcmV0Jng9ZDI")
weather.location = {lat: 35.649657, lng: 139.752162}
weather.sync

notifier = Slack::Notifier.new "https://hooks.slack.com/services/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"
notifier.ping "Bot started"

p ["Bot started"]
p ["local port is #{ENV["PORT"]}"]

counter = 1
EM::defer do
  loop do
    # sync weather and notify messages
    sleep 10*60
    counter += 1
    weather.sync
    notifier.ping notification_messages
    #notifier.set_sended_flag

    # polling self to prevent sleep
    open("http://localhost:#{ENV["PORT"]}/")
  end
end

get '/heartbeat' do
  "OK"
end

get '/force-sync' do
  weather.sync
  "OK"
end



# For debug
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

get '/debug/notification_messages' do
  content_type 'text/plain'
  PP.pp(weather.notification_messages, '')
end

get '/debug/counter' do
  counter.to_s
end
