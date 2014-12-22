# -*- coding: utf-8 -*-
require 'spec_helper'
require 'notifications_generator'

describe NotificationsGenerator do
  before do
    Time.zone = "Asia/Tokyo"
  end

  describe "#create_notifications" do
    it "should create notifications" do
      list = [{time: Time.zone.parse("2014-12-23 20:00"), fine: true},
              {time: Time.zone.parse("2014-12-23 20:05"), fine: false},
              {time: Time.zone.parse("2014-12-23 20:10"), fine: true}]
      ns = NotificationsGenerator.create_notifications(list)
      expect(ns.length).to eq 3
      expect(ns[0].type).to eq :fine
      expect(ns[1].type).to eq :rain_once
      expect(ns[2].type).to eq :fine
    end
  end

  describe "#make_edges" do
    it "should return edge notifications" do
      ns = Notifications.new
      ns << Notification.new(time: Time.zone.parse("2014-12-23 19:55"), fine: true)  #0
      ns << Notification.new(time: Time.zone.parse("2014-12-23 20:00"), fine: true)  #1
      ns << Notification.new(time: Time.zone.parse("2014-12-23 20:05"), fine: false) #2
      ns << Notification.new(time: Time.zone.parse("2014-12-23 20:10"), fine: false) #3
      ns << Notification.new(time: Time.zone.parse("2014-12-23 20:15"), fine: true)  #4
      ns << Notification.new(time: Time.zone.parse("2014-12-23 20:20"), fine: true)  #5
      Timecop.freeze(Time.zone.parse("2014-12-23 20:00")) do
        edges = NotificationsGenerator.make_edges(ns)
        expect(edges.length).to eq 3
        expect(edges[0]).to eq ns[1]
        expect(edges[1]).to eq ns[2]
        expect(edges[2]).to eq ns[4]
      end
    end
  end

  describe "#resolve_type" do
    it "should resolve type and duration" do
      ns = Notifications.new
      ns << Notification.new(time: Time.zone.parse("2014-12-23 20:00"), fine: true)  #0
      ns << Notification.new(time: Time.zone.parse("2014-12-23 20:05"), fine: false) #1
      ns << Notification.new(time: Time.zone.parse("2014-12-23 20:10"), fine: true)  #2
      ns << Notification.new(time: Time.zone.parse("2014-12-23 20:20"), fine: false) #3
      ret = NotificationsGenerator.resolve_type(ns)
      expect(ret[0].type).to eq :fine
      expect(ret[0].duration).to eq nil
      expect(ret[1].type).to eq :rain_once
      expect(ret[1].duration).to eq 300
      expect(ret[2].type).to eq :fine_once
      expect(ret[2].duration).to eq 600
      expect(ret[3].type).to eq :rain
      expect(ret[3].duration).to eq nil
    end
  end
end
