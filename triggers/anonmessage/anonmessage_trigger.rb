# anonmessage_trigger.rb - relays messages from some users anonymously
# Copyright (C) 2014 raymoo
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
require 'fileutils'
require 'uri'

Trigger.new do |t|
  t[:id] = 'mess'
  t[:cooldown] = 20
  t[:lastused] = Hash.new
  t[:lastused].default = Time.now - t[:cooldown]


  t.match { |info|
    # checks
    info[:where] == 'pm' &&
    info[:what][0..4] == '!mess' &&
    info[:what].size > 5 &&
    info[:what][5..-1].strip
  }

  FileUtils.mkdir_p("./#{ch.dirname}/anonmessage")
  accesslist_path = "./#{ch.dirname}/anonmessage/access"
  File.touch(accesslist_path)

  t.act { |info|
    who = CBUtils.condense_name(info[:who])

    # gets arguments
    args = info[:result].split(', ')

    if args[0][0] == '#' && !File.read(accesslist_path).split("\n").index(who)
      info[:respond].call("You do not have permission to send messages to rooms")
      next
    end

    if args.count < 2
      info[:respond].call("You need to specify a destination and message")
    else
      # is it a room
      if args[0][0] == '#' && args[0].size > 1
        result = args[0][1..-1] + '|'
      else
        # placeholder until I figure out things
        result = '|/pm ' + args[0] + ', '
      end

      result += 'Anonymous Message: ' + args[1..-1].join(", ")

      t[:lastused][who] + t[:cooldown] < Time.now or (info[:respond].call("You may only send messages once every 20 seconds") or next)
      t[:lastused][who] = Time.now

    end

    #sends message
    info[:ws].send(result)
  }
end
