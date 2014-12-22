# -*- coding: utf-8 -*-

class Notification
  attr_accessor :type  # :fine, :rain, :fine_once or :rain_once
  attr_accessor :time
  attr_accessor :fine
  attr_accessor :duration
  attr_accessor :sended

  def initialize(type: nil, time: nil, fine: nil, duration: nil, sended: false)
    self.type = type
    self.time = time
    self.fine = fine
    self.duration = duration
    self.sended = sended
  end

  def key
    self.time.to_i.to_s + ":" + self.type.to_s + ":" + self.duration.to_s
  end

  def <=> (other)
    if self.time == other.time
      self.type_to_i <=> other.type_to_i
    else
      self.time <=> other.time
    end
  end

  def type_to_i
    case self.type
    when :fine
      1
    when :rain
      2
    when :fine_once
      3
    when :rain_once
      4
    end
  end
end
