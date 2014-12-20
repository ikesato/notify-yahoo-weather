# -*- coding: utf-8 -*-
require 'open-uri'
require 'json'
require 'active_support/time'
require 'pp'


class YolWeather
  attr_accessor :location
  attr_accessor :appid

  def initialize(appid: nil, location: nil)
    @appid = appid
  end

  def sync
    return nil if @appid.nil?
    return nil if @location.nil?
    return nil unless lat = @location[:lat]
    return nil unless lng = @location[:lng]

    begin
      url = "http://weather.olp.yahooapis.jp/v1/place?coordinates=#{lng},#{lat}&appid=#{appid}&output=json&interval=5"
      STDERR.puts(url)
      @weather = JSON.parse(open(url).read)

      last_tz = Time.zone
      Time.zone = "Asia/Tokyo"
      make_notifications
    rescue => ex
      STDERR.puts(ex)
      STDERR.puts(ex.backtrace)
    ensure
      Time.zone = last_tz if last_tz
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
  # 一つの通知は以下のいずれか
  # 1. fine      : ?時?分に晴れます
  # 2. rain      : ?時?分に雨が降ります
  # 3. fine-once : ?時?分からN分間だけ晴れます
  # 4. rain-once : ?時?分からN分間だけ雨が降ります
  #
  # 60分後までの通知を配列でまとめる
  #
  # 備考
  # 地点は見ない
  # FeatureWeatherList だけ参照
  def make_notifications
    # Detect edge weather
    edges = []
    futures = @weather["Feature"].first["Property"]["WeatherList"]["Weather"]
    futures.each do |f|
      status = {time: Time.zone.parse(f["Date"]), fine: f["Rainfall"].to_f == 0.0}
      @last_observation = status if f["Type"] == "observation"
      el = edges.last
      edges << status if el.nil? || el[:fine] != status[:fine]
    end

    # Resolv status and duration
    edges.each_with_index do |e, i|
      if i == 0
        e[:status] = :fine
      elsif i == edges.length-1
        e[:status] = :rain
      else
        if e[:fine]
          e[:status] = :fine_once
        else
          e[:status] = :rain_once
        end
        e[:duration] = edges[i+1][:time] - e[:time]
      end
    end

    # Merge last_notifications
    ns = []
    @last_notifications
  end

end
