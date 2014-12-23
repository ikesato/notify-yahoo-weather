# -*- coding: utf-8 -*-
require 'spec_helper'
require 'notification'

describe Notification do
  describe "#initialize" do
    it "should set fields" do
      now = Time.now
      n = Notification.new(type: :fine, time: now, fine: true, duration: 300, sended: true)
      expect(n.type).to eq :fine
      expect(n.time).to eq now
      expect(n.fine).to eq true
      expect(n.duration).to eq 300
      expect(n.sended).to eq true
    end

    it "should not set default values without no args" do
      n = Notification.new
      expect(n.type).to be_nil
      expect(n.time).to be_nil
      expect(n.fine).to be_nil
      expect(n.duration).to be_nil
      expect(n.sended).to eq false
    end
  end

  describe "#key" do
    it "should set correct key" do
      n = Notification.new(time: Time.at(123), type: :rain, duration: 12345)
      expect(n.key).to eq "123:rain:12345"
    end

    it "should set correct key when duration is nil" do
      n = Notification.new(time: Time.at(123), type: :rain)
      expect(n.key).to eq "123:rain:"
    end
  end

  describe "==" do
    it "should return true when same objects" do
      n1 = Notification.new(time: Time.at(1001))
      n2 = Notification.new(time: Time.at(1001))
      expect(n1 == n2).to eq true
    end

    it "should return false when differenct objects" do
      n1 = Notification.new(time: Time.at(1001))
      n2 = Notification.new(time: Time.at(1002))
      expect(n1 == n2).to eq false
    end
  end

  describe "#eql_without_sended?" do
    it "should return false when differenct objects" do
      n1 = Notification.new(time: Time.at(1001), sended: true)
      n2 = Notification.new(time: Time.at(1001), sended: false)
      expect(n1.eql_without_sended?(n2)).to eq true
      expect(n1 == n2).to eq false
    end
  end


  describe "<=>" do
    it "should order correctly" do
      n0 = Notification.new(time: Time.at(1001), type: :rain)
      n1 = Notification.new(time: Time.at(1002), type: :fine)
      n2 = Notification.new(time: Time.at(1002), type: :rain)
      n3 = Notification.new(time: Time.at(1002), type: :fine_once)
      n4 = Notification.new(time: Time.at(1002), type: :rain_once)
      n5 = Notification.new(time: Time.at(1003), type: :fine)
      ary = [n5, n4, n3, n2, n1, n0].sort
      expect(ary[0].key).to eq n0.key
      expect(ary[1].key).to eq n1.key
      expect(ary[2].key).to eq n2.key
      expect(ary[3].key).to eq n3.key
      expect(ary[4].key).to eq n4.key
      expect(ary[5].key).to eq n5.key
    end
  end
end
