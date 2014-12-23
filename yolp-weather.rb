# -*- coding: utf-8 -*-
require 'open-uri'
require 'json'
require 'active_support/time'
require 'notification'
require 'notifications'
require 'notifications_generator'
require 'pp'


class YolpWeather
  attr_accessor :location
  attr_accessor :appid
  attr_reader :weather, :notifications

  def initialize(appid: nil, location: nil)
    @appid = appid
    @location = location
    @notifications = Notifications.new
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

      Time.zone = "Asia/Tokyo"
      make_notifications
    rescue => ex
      STDERR.puts(ex)
      STDERR.puts(ex.backtrace)
    end
  end

  def notification_message(ignore_sended: false)
    messages = []
    @notifications.each do |n|
      next if ignore_sended == false && n.sended
      messages << make_notification_message(n)
    end
    messages.join("\n")
  end

  def set_sended_flags
    @notifications.each do |n|
      n.sended = true
    end
  end

  def current_wheather
    Time.zone = "Asia/Tokyo"
    now = Time.zone.now
    last = @notifications.first
    @notifications.each do |n|
      break if n.time > now
      last = n
    end
    last
  end


  private

  # 通知すべきリストを作成する
  #
  # 一つの通知は以下のいずれか
  # 1. ?時?分に晴れます
  # 2. ?時?分に雨が降ります
  # 3. ?時?分からN分間だけ晴れます
  # 4. ?時?分からN分間だけ雨が降ります
  #
  # 60分後までの通知を配列でまとめる
  #
  # 備考
  # 地点は見ない
  # FeatureWeatherList だけ参照
  def make_notifications
    list = []
    ws = @weather["Feature"].first["Property"]["WeatherList"]["Weather"]
    ws.map do |w|
      next if w["Type"] != "forecast"
      list << {time: Time.zone.parse(w["Date"]), fine: w["Rainfall"].to_f == 0.0}
    end
    current_ns = NotificationsGenerator.create_notifications(list)
    @notifications.merge(current_ns)
  end

  def make_notification_message(n)
    case n.type
    when :fine
      n.time.strftime("%H時%M分に晴れます。")
    when :rain
      n.time.strftime("%H時%M分に雨が降ります。")
    when :fine_once
      "#{n.time.strftime("%H時%M分")}から#{n.duration/60}分間だけ晴れます。"
    when :rain_once
      "#{n.time.strftime("%H時%M分")}から#{n.duration/60}分間だけ雨が降ります。"
    end
  end
end
