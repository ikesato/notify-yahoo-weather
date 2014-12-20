# -*- coding: utf-8 -*-
require 'open-uri'
require 'json'
require 'pp'


class YolWeather
  attr_accessor :location
  attr_accessor :appid
  attr_accessor :last_status

  def initialize(appid: nil, location: nil)
    @appid = appid
    @last_status = {time: nil, fine: nil}
  end

  def sync
    return nil if @appid.nil?
    return nil if @location.nil?
    return nil unless lat = @location[:lat]
    return nil unless lng = @location[:lng]

    begin
      weather = JSON.parse(open("http://weather.olp.yahooapis.jp/v1/place?coordinates=#{lng},#{lat}&appid=#{appid}&output=json&interval=5").read)
    rescue => ex
      STDERR.puts(ex)
      STDERR.puts(ex.backtrace)
    end
  end

  # 通知すべきリストを作成する
  # 備考
  # 地点は見ない
  # FeatureWeatherList だけ参照
  def notifications
    futures = weather["Feature"].first["Property"]["WeatherList"]["Weather"]
    futures.each do |f|
      t = Time.parse(f["Date"])
      if f["Type"] == "observation"
        @last_status = {time: t, fine: f["Rainfall"].to_f == 0.0}
      end
    end
  end

  def last_weather
    weather
  end
end
