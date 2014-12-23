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
  p request.body.read
  {text: "OK"}.to_json
end

route :get, :post, '/show-notifications' do
  content_type 'application/json; charset=utf-8'
  p request.body.read
  {text: weather.notification_message(ignore_sended: true)}.to_json
end

route :get, :post, '/current-weather' do
  content_type 'application/json; charset=utf-8'
  cw = weather.current_wheather
  if cw
    text = cw.fine? ? "晴れ" : "雨"
  else
    text = "不明"
  end
  {text: text}.to_json
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
