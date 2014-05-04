# fetlist trigger - uploads fetish data as a list to hastebin and posts the link
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

def count_stats(fetish, path)
  result = [0, 0, 0, 0, 0]
  path = path + '/' + fetish
  FileUtils.touch(path)
  entries = File.read(path).split("\n")

  entries.each {|entry|
    elements = entry.split(' ')
    elementnum = elements[1]
    result[Integer(elements[1])] += 1
  }

  result

end

Trigger.new do |t|
  t[:id] = "!fetlist"
  t[:nolog] = true
  
  t.match { |info|
    info[:what].downcase == '!fetlist'
  }
  
  stats_path = './showderp/fetishtracker/stats'
  FileUtils.touch(stats_path)
  uploader = CBUtils::HasteUploader.new
  
  t.act do |info|
    
    stats = File.read('./showderp/fetishtracker/list').split(' ')
    stats_text = "Fetish|ban|warning|no warning|declare|love\n"
    
    stats.each {|fetish|
      stats_text += fetish + "|" + count_stats(fetish, stats_path).join("|") + "\n"
    }
  
    uploader.upload(stats_text) do |url|
      info[:respond].call(url)
    end
    
  end
end
