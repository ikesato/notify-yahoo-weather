# -*- coding: utf-8 -*-

require 'notification'

# Array of Notification
class Notifications < Array
  def merge(notifications)
    # Merge notifications
    ln = @notifications.last
    if ln && notifications.first.type != ln.type
      # TODO:UT
      notifications.shift
    end
    notifications.each do |e|
      next if @notifications.any? do |n|
        # TODO:UT true
        n[:key] == e[:key]
      end
      # TODO:UT
      @notifications << e
    end
    pp ["aaaaaaaaa 2", notifications]
    pp ["aaaaaaaaa 2.2", @notifications]

    # Sort
    @notifications.sort do |a,b|
      if a.time == b.time
        # TODO:UT
        status_to_i(a.type) <=> status_to_i(b.type)
      else
        a.time <=> b.time
      end
    end
    pp ["aaaaaaaaa 3", @notifications]

    # Uniq
    ln = nil
    @notifications.delete_if do |n|
      if ln && ln.time == n.time
        # TODO:UT
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
      n.time < Time.zone.now
    end

    # 最後の一つは必ず残す
    @notifications << ln if @notifications.empty?
    pp ["aaaaaaaaa 6", @notifications]
  end
end
