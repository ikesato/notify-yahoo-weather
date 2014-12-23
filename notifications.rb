# -*- coding: utf-8 -*-

require 'notification'

# Array of Notification
class Notifications < Array
  def merge(notifications)
    ns = notifications

    # Merge notifications
    if ns && !ns.empty?
      if self.last && self.last.time < ns.first.time && self.last.type == ns.first.type
        ns.shift
      end
      ns.each do |n|
        next if self.include_without_sended? n
        self << n
      end
    end

    if ns && !ns.empty?
      # Remove future notifications if not contain new notifications
      self.delete_if do |n|
        if ns.first.time <= n.time
          !ns.include_without_sended? n
        else
          false
        end
      end
    end

    # Save last element
    ln = self.last

    # Remove old notifications without first element
    self.delete_if do |n|
      n.time < Time.zone.now
    end

    # Restore last element when empty
    self << ln if ln && self.empty?

    # Sort & Uniq
    self.sort!
    self.uniq!
  end

  def include_without_sended?(notification)
    self.any? do |sn|
      notification.eql_without_sended? sn
    end
  end

  def uniq
    super do |n|
      n.as_json
    end
  end

  def uniq!
    super do |n|
      n.as_json
    end
  end
end
