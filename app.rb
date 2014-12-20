# -*- coding: utf-8 -*-
require 'sinatra'
#require 'eventmachine'

#run Sinatra::Application

get '/hello' do
  "world"
end

#EM::defer do
#  loop do
#    sleep 5
#    next if @@jobs.empty?
#    job = @@jobs.shift ## ジョブ1つ取り出す
#    ## job処理する
#  end
#end

