# -*- coding: utf-8 -*-
require 'spec_helper'
require 'yolp-weather'

describe YolpWeather do
  it "should set appid and location" do
    w = YolpWeather.new(appid: "abc", location: {lat: 35.0, lng: 139.0})
    expect(w.appid).to eq "abc"
    expect(w.location).to eq({lat: 35.0, lng: 139.0})
  end

  describe "#sync" do
    before do
      @w = YolpWeather.new
      @w.appid = "abc"
      @w.location = {lat: 35.0, lng: 139.0}
      allow_any_instance_of(Kernel).to receive(:open).and_return("")
      allow_any_instance_of(String).to receive(:read).and_return(File.read("spec/yolp-weather-normal.json"))
    end

    it "should request to yahoo API" do
      expect(@w).to receive(:make_notifications)
      @w.sync
    end

    it "should return nil when invalid parameter" do
      expect(@w).not_to receive(:make_notifications)
      @w.appid = nil
      @w.sync
    end
  end

  describe "#sync -> #make_notifications" do
    before do
      @w = YolpWeather.new
      @w.appid = "abc"
      @w.location = {lat: 35.0, lng: 139.0}
      allow_any_instance_of(Kernel).to receive(:open).and_return("")
      allow_any_instance_of(String).to receive(:read).and_return(File.read("spec/yolp-weather-normal.json"))
    end

    it "should generate notifications" do
      Time.zone = "Asia/Tokyo"
      Timecop.freeze(Time.zone.parse("2014-12-09 20:10")) do
        @w.sync
      end
    end
  end
end
