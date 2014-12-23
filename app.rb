# -*- coding: utf-8 -*-
#p File.dirname(__FILE__)
$LOAD_PATH << File.dirname(__FILE__)

require 'sinatra'
require 'sinatra/multi_route'
require 'eventmachine'
require 'slack-notifier'
require 'open-uri'
require 'yolp-weather'
require 'pp'

weather = YolpWeather.new(appid: "dj0zaiZpPTZpTUZRUzI3MmN4WiZzPWNvbnN1bWVyc2VjcmV0Jng9ZDI")
weather.location = {lat: 35.649657, lng: 139.752162}
weather.sync
weather.set_sended_flags # set sended flags at firsttime

notifier = Slack::Notifier.new "https://hooks.slack.com/services/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"
notifier.ping "Bot started"

p "Bot started"

counter = 1
EM::defer do
  loop do
    # sync weather and notify messages
    sleep 10*60
    counter += 1
    weather.sync
    msg = weather.notification_message
    notifier.ping msg if msg && !msg.empty?
    weather.set_sended_flags

    # polling self to prevent sleep
    open("https://sinatra-demo-20141027.herokuapp.com/heartbeat")
  end
end

get '/heartbeat' do
  "OK"
end

get '/force-sync' do
  weather.sync
  "OK"
end

post '/out-going' do
  content_type 'application/json; charset=utf-8'
  p request.body.read
  p params[:text]
  text = params[:text]
  if text =~ /^今の天気/
    cw = weather.current_wheather
    response = cw ? (cw.fine? ? "晴れ" : "雨") : "不明"
  elsif text =~ /^今の通知は？/
    response = weather.notification_message(ignore_sended: true)
  elsif text =~ /^debug|デバッグ/
    json = {now: Time.now.to_s, counter: counter, weather: weather.weather, notifications: weather.notifications}
    response = PP.pp(json, '')
  end
  {text: response}.to_json
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

get '/debug/counter' do
  counter.to_s
end
