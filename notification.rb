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

  def fine?
    self.type == :fine ||  self.type == :fine_once
  end

  def rain?
    self.type == :rain ||  self.type == :rain_once
  end

  def == (other)
    self.eql_without_sended?(other) &&
    self.sended == other.sended
  end

  def eql_without_sended?(other)
    self.type == other.type &&
    self.time == other.time &&
    self.fine == other.fine &&
    self.duration == other.duration
  end

  def <=> (other)
    if self.time != other.time
      return self.time <=> other.time
    end
    self.type_to_i <=> other.type_to_i
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

  def as_json
    {type: self.type, time: self.time, fine: self.fine,
      duration: self.duration, sended: self.sended}
  end
end
