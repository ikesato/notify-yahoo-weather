# -*- coding: utf-8 -*-
require 'sinatra'
require 'eventmachine'

#run Sinatra::Application

counter = 1

EM::defer do
  loop do
    sleep 5
    counter += 1
  end
end

get '/hello' do
  "world #{counter}"
end
