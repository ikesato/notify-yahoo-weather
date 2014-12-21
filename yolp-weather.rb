# -*- coding: utf-8 -*-
require 'open-uri'
require 'json'
require 'active_support/time'
require 'pp'


class YolWeather
  attr_accessor :location
  attr_accessor :appid
  attr_reader :weather, :notifications

  def initialize(appid: nil, location: nil)
    @appid = appid
    @notifications = []
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

  def notification_messages
    messages = []
    @notifications.each do |n|
      next if n[:sended]
      messages << make_notification_message(n)
    end
    messages
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
    # Detect weather edges
    edges = []
    futures = @weather["Feature"].first["Property"]["WeatherList"]["Weather"]
    futures.each do |f|
      next if f["Type"] != "forecast"
      status = {time: Time.zone.parse(f["Date"]), fine: f["Rainfall"].to_f == 0.0}
      edges << status if edges.last.nil? || edges.last[:fine] != status[:fine]
    end
    pp ["aaaaaaaaa 0", futures]

    # Resolve status and duration and key
    edges.each_with_index do |e, i|
      if i == 0 || i == edges.length-1
        e[:status] = e[:fine] ? :fine : :rain
      else
        e[:status] = e[:fine] ? :fine_once : :rain_once
        e[:duration] = edges[i+1][:time] - e[:time]
      end
      e[:key] = e[:time].to_i.to_s + ":" + e[:status].to_s + ":" + e[:duration].to_s
    end
    pp ["aaaaaaaaa 1", edges]

    # Merge notifications
    ln = @notifications.last
    if ln && edges.first[:status] != ln[:status]
      edges.shift
    end
    edges.each do |e|
      next if @notifications.any? do |n|
        n[:key] == e[:key]
      end
      @notifications << e
    end
    pp ["aaaaaaaaa 2", edges]
    pp ["aaaaaaaaa 2.2", @notifications]

    # Sort
    @notifications.sort do |a,b|
      if a[:time] == b[:time]
        status_to_i(a[:status]) <=> status_to_i(b[:status]) 
      else
        a[:time] <=> b[:time]
      end
    end
    pp ["aaaaaaaaa 3", @notifications]

    # Uniq
    ln = nil
    @notifications.delete_if do |n|
      if ln && ln[:time] == n[:time]
        true
      else
        ln = n
        false
      end
    end
    pp ["aaaaaaaaa 4", @notifications]

    # Remove old notifications
    ln = @notifications.last
    @notifications.delete_if do |n|
      n[:time] < Time.zone.now
    end
    pp ["aaaaaaaaa 5", @notifications]

    # 最後の一つは必ず残す
    @notifications << ln if @notifications.empty?
    pp ["aaaaaaaaa 6", @notifications]
  end

  def status_to_i(status)
    case status
    when :fine
      2
    when :rain
      1
    when :fine_once
      4
    when :rain_once
      3
    end
  end

  def make_notification_message(n)
    case n[:status]
    when :fine
      n[:time].strftime("%H時%M分に晴れます。")
    when :rain
      n[:time].strftime("%H時%M分に雨が降ります。")
    when :fine_once
      "#{n[:time].strftime("%H時%M分")}から#{n[:duration]/60}分間だけ晴れます。"
    when :rain_once
      "#{n[:time].strftime("%H時%M分")}から#{n[:duration]/60}分間だけ雨が降ります。"
    end
  end
end
