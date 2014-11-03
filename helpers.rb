require 'sinatra/base'

module Sinatra
  
  module DataHelpers
    def make_row(cells)
      "<tr>" << cells.map { |cell| "<td>#{cell}</td>" }.join << "</tr>"
    end
    
    def make_table(rows)
      "<table>" << rows.map { |row| make_row(row) }.join << "</table>"
    end
    
    def stats_to_table(stats)
      stats = stats.split("\n").map { |row| row.split(%r{\s+}) }
      make_table(stats)
    end
    
    def get_memory
      data = `free -m | grep 'Mem'`.scan(/\w+/).drop(1)
      
      table = "<table><tr>"
      table << ['total', 'used', 'free', 'shared', 'buffers', 'cached'].map do |d|
        "<td>#{d.capitalize}</td>"
      end.join << "</tr>"
      
      table << data.map do |d|
        "<td>#{d}</td>"
      end.join
      table << "</tr></table>"
    end
  end
  
  helpers DataHelpers
  
end
