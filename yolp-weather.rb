# -*- coding: utf-8 -*-
require 'open-uri'
require 'json'
require 'active_support/time'
require 'pp'


class YolWeather
  attr_accessor :location
  attr_accessor :appid

  def initialize(appid: nil, location: nil)
    Time.zone = "Asia/Tokyo"
    @appid = appid
  end

  def sync
    return nil if @appid.nil?
    return nil if @location.nil?
    return nil unless lat = @location[:lat]
    return nil unless lng = @location[:lng]

    begin
      url = "http://weather.olp.yahooapis.jp/v1/place?coordinates=#{lng},#{lat}&appid=#{appid}&output=json&interval=5"
      @weather = JSON.parse(open(url).read)
    rescue => ex
      STDERR.puts(ex)
      STDERR.puts(ex.backtrace)
    end
  end

  def notifications
  end

  def last_weather
    @weather
  end


  private

  # 通知すべきリストを作成する
  #
  # 備考
  # 地点は見ない
  # FeatureWeatherList だけ参照
  def make_notifications
    edges = []
    futures = weather["Feature"].first["Property"]["WeatherList"]["Weather"]
    futures.each do |f|
      status = {time: Time.zone.parse(f["Date"]), fine: f["Rainfall"].to_f == 0.0}
      @last_observation = status if f["Type"] == "observation"
      el = edges.last
      edges << status if el.nil? || el[:fine] != fine
    end

    need_notify = false
  end

end
