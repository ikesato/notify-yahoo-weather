# -*- coding: utf-8 -*-
require 'sinatra'
require 'eventmachine'
require 'slack-notifier'
require './yolp-weather'

#weather = YolWeather.new(appid: "dj0zaiZpPTZpTUZRUzI3MmN4WiZzPWNvbnN1bWVyc2VjcmV0Jng9ZDI")
#weather.location = {lat: 35.649657, lng: 139.752162}
#weather.sync
#exit

counter = 1
EM::defer do
  loop do
    sleep 10*60
    counter += 1
    #weather.sync
  end
end

get '/hello' do
  "world #{counter}"
end

get '/now' do
  Time.now.to_s
end


#notifier = Slack::Notifier.new "https://hooks.slack.com/services/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"
#notifier.ping "Hello World 101

#location = {lat: 35.649657, lng: 139.752162}
#appid = "dj0zaiZpPTZpTUZRUzI3MmN4WiZzPWNvbnN1bWVyc2VjcmV0Jng9ZDI"
#
#pp a
