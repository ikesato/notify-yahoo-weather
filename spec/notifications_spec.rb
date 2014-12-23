# -*- coding: utf-8 -*-
require 'spec_helper'
require 'notifications'
require 'notifications_generator'
require 'active_support/time'

describe Notifications do
  before do
    Time.zone = "Asia/Tokyo"
    Timecop.freeze(Time.zone.parse("2014-12-23 20:00"))
  end

  describe "#merge" do
    it "should remove first element when last element type was same" do
      ns1 = NotificationsGenerator.create_notifications(
          [{time: Time.zone.parse("2014-12-23 20:00"), fine: true}])
      ns2 = NotificationsGenerator.create_notifications(
          [{time: Time.zone.parse("2014-12-23 20:05"), fine: true}])
      ns1.merge(ns2)
      expect(ns1.length).to eq 1
      expect(ns1.first.time).to eq Time.zone.parse("2014-12-23 20:00")
    end

    it "should not remove first element when last element type was different" do
      ns1 = NotificationsGenerator.create_notifications(
          [{time: Time.zone.parse("2014-12-23 20:00"), fine: true}])
      ns2 = NotificationsGenerator.create_notifications(
          [{time: Time.zone.parse("2014-12-23 20:05"), fine: false}])
      ns1.merge(ns2)
      expect(ns1.length).to eq 2
      expect(ns1.first.time).to eq Time.zone.parse("2014-12-23 20:00")
      expect(ns1.last.time).to eq Time.zone.parse("2014-12-23 20:05")
    end

    it "should not remove first element when last element type was different" do
      ns1 = NotificationsGenerator.create_notifications(
          [{time: Time.zone.parse("2014-12-23 20:00"), fine: true}])
      ns2 = NotificationsGenerator.create_notifications(
          [{time: Time.zone.parse("2014-12-23 20:05"), fine: false}])
      ns1.merge(ns2)
      expect(ns1.length).to eq 2
      expect(ns1.first.time).to eq Time.zone.parse("2014-12-23 20:00")
      expect(ns1.last.time).to eq Time.zone.parse("2014-12-23 20:05")
    end

    it "should skip sended element" do
      ns1 = Notifications.new
      ns1 << Notification.new(time: Time.zone.parse("2014-12-23 20:00"), type: :fine, sended: true)
      ns1 << Notification.new(time: Time.zone.parse("2014-12-23 20:05"), type: :rain, sended: true)
      ns1 << Notification.new(time: Time.zone.parse("2014-12-23 20:10"), type: :fine, sended: true)

      ns2 = Notifications.new
      ns2 << Notification.new(time: Time.zone.parse("2014-12-23 20:05"), type: :rain, sended: false)
      ns2 << Notification.new(time: Time.zone.parse("2014-12-23 20:10"), type: :fine, sended: false)
      ns2 << Notification.new(time: Time.zone.parse("2014-12-23 20:15"), type: :rain, sended: false)

      ns1.merge(ns2)
      expect(ns1.length).to eq 4
      expect([ns1[0].time, ns1[0].sended]).to eq [Time.zone.parse("2014-12-23 20:00"), true]
      expect([ns1[1].time, ns1[1].sended]).to eq [Time.zone.parse("2014-12-23 20:05"), true]
      expect([ns1[2].time, ns1[2].sended]).to eq [Time.zone.parse("2014-12-23 20:10"), true]
      expect([ns1[3].time, ns1[3].sended]).to eq [Time.zone.parse("2014-12-23 20:15"), false]
    end

    it "should remove past element without last element" do
      ns = Notifications.new
      ns << Notification.new(time: Time.zone.parse("2014-12-23 19:00"), type: :fine, sended: true)
      ns << Notification.new(time: Time.zone.parse("2014-12-23 19:05"), type: :rain, sended: true)
      ns.merge(nil)
      expect(ns.length).to eq 1
      expect(ns[0].time).to eq Time.zone.parse("2014-12-23 19:05")
    end

    it "should remove when notifications was changed" do
      ns1 = Notifications.new
      ns1 << Notification.new(time: Time.zone.parse("2014-12-23 20:00"), type: :fine, sended: true)
      ns1 << Notification.new(time: Time.zone.parse("2014-12-23 20:05"), type: :rain, sended: true)
      ns1 << Notification.new(time: Time.zone.parse("2014-12-23 20:10"), type: :fine, sended: true)

      ns2 = Notifications.new
      ns2 << Notification.new(time: Time.zone.parse("2014-12-23 20:05"), type: :fine, sended: false)
      ns2 << Notification.new(time: Time.zone.parse("2014-12-23 20:10"), type: :rain, sended: false)
      ns2 << Notification.new(time: Time.zone.parse("2014-12-23 20:15"), type: :fine, sended: false)

      ns1.merge(ns2)
      expect(ns1.length).to eq 4
      expect([ns1[0].time, ns1[0].type, ns1[0].sended]).to eq [Time.zone.parse("2014-12-23 20:00"), :fine, true]
      expect([ns1[1].time, ns1[1].type, ns1[1].sended]).to eq [Time.zone.parse("2014-12-23 20:05"), :fine, false]
      expect([ns1[2].time, ns1[2].type, ns1[2].sended]).to eq [Time.zone.parse("2014-12-23 20:10"), :rain, false]
      expect([ns1[3].time, ns1[3].type, ns1[3].sended]).to eq [Time.zone.parse("2014-12-23 20:15"), :fine, false]
    end
  end

  describe "#include_without_sended?" do
    it "should return true when same elements without sended" do
      ns = Notifications.new
      ns << Notification.new(time: Time.at(1001), sended: true)
      n   = Notification.new(time: Time.at(1001), sended: false)
      expect(ns.include_without_sended? n).to eq true
      expect(ns.include? n).to eq false
    end
  end

  describe "#uniq and #uniq!" do
    it "should remove uniqueue element" do
      n0 = Notification.new(time: Time.at(1001), type: :rain)
      n1 = Notification.new(time: Time.at(1002), type: :fine)
      n2 = Notification.new(time: Time.at(1002), type: :fine)
      n3 = Notification.new(time: Time.at(1002), type: :fine_once)
      n4 = Notification.new(time: Time.at(1002), type: :fine_once)
      n5 = Notification.new(time: Time.at(1003), type: :fine)
      n6 = Notification.new(time: Time.at(1001), type: :rain)
      ns = Notifications.new([n0, n1, n2, n3, n4, n5, n6])
      expect(ns.class).to eq Notifications
      # uniq and uniq! are same result
      [ns.uniq, ns.uniq!].each do |ary|
        expect(ary.length).to eq 4
        expect(ary[0]).to eq n0
        expect(ary[1]).to eq n1
        expect(ary[2]).to eq n3
        expect(ary[3]).to eq n5
      end
    end
  end
end
