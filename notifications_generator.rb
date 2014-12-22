# -*- coding: utf-8 -*-
require 'active_support/time'
require 'notifications'

class NotificationsGenerator
  # Create notifications from array of hash
  def self.create_notifications(weathers)
    notifications = Notifications.new
    weathers.map do |w|
      n = Notification.new
      n.time = w[:time]
      n.fine = w[:fine]
      notifications << n
    end
    notifications = make_edges(notifications)
    resolve_type(notifications)
  end

  # Make edge notifications
  def self.make_edges(notifications)
    edges = Notifications.new
    notifications.each do |n|
      next if n.time < Time.zone.now
      edges << n if edges.last.nil? || edges.last.fine != n.fine
    end
    edges
  end

  # Resolve status and duration and key
  def self.resolve_type(notifications)
    ns = notifications
    ns.each_with_index do |n, i|
      if i == 0 || i == ns.length-1
        n.type = n.fine ? :fine : :rain
        n.duration = nil
      else
        n.type = n.fine ? :fine_once : :rain_once
        n.duration = ns[i+1].time - n.time
      end
    end
    ns
  end
end
