require 'sinatra/base'

module Sinatra

  module MongoHelpers
    
    # a helper method to turn a string ID
    # representation into a BSON::ObjectId
    def object_id val
      BSON::ObjectId.from_string(val)
    end
    
    def document_by_id id
      id = object_id(id) if String === id
      settings.mongo_db['memory'].find_one(:_id => id).to_json
    end

  end
 
  module DataHelpers
    
    def make_table(rows)
      def make_row(cells)
        "<tr>" << cells.map { |cell| "<td>#{cell}</td>" }.join << "</tr>"
      end
      "<table>" << rows.map { |row| make_row(row) }.join << "</table>"
    end
    
    def disk
      `df -h`.sub!('Mounted on', 'Mounted_on').split("\n").map { |row| row.split(%r{\s+}) }
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

    def memory
      data = `free -m | grep 'Mem'`.scan(/\w+/).drop(1)
      names = ['total', 'used', 'free', 'shared', 'buffers', 'cached']
      memory = {}
      0.upto(data.length - 1) do |i|
        memory[names[i]] = data[i]
      end
      memory["time"] = Time.now
      memory
    end

    def memory_history

      def make_row row_data
        row = "<tr>"
        row_data.values.drop(1).map do |td|
          row << "<td>#{td}</td>"
        end
        row << "</tr>"
      end

      def make_header_row
        header_row = "<tr>"
        names = ['total', 'used', 'free', 'shared', 'buffers', 'cached', 'time']
        header_row << names.map { |n| "<td>#{n.capitalize}</td>" }.join
        header_row << "</tr>"
      end

      mem_history = settings.mongo_db['memory'].find.to_a

      table = "<table>"
      table << make_header_row
      
      mem_history.each do |row_data|
        table << make_row(row_data)
      end
      
      table << "</table>"
    end
    
    def save_memory_data
      settings.mongo_db['memory'].insert memory
    end

    def save_disk_data
      disk_data = disk
      document = {"array" => Array.new, "time" => Time.now}
      def make_doc(row)
        doc = {}
        names = ['filesystem', 'size', 'used', 'avail', 'use%', 'mounted_on']
        row.each_with_index do |value, index|
          doc[names[index]] = row[index]
        end
        doc
      end
      disk_data.each_with_index do |row, index|
        document["array"].push(make_doc(row)) unless index == 0
      end
      settings.mongo_db['disk'].insert document
    end

    def disk_history
      data = settings.mongo_db['disk'].find.to_a
      table = "<table><tr><td>Time</td><td>Size</td><td>Used</td></tr>"
      data.each do |r|
        table << "<tr><td>#{r["time"]}</td><td>#{r["array"][0]["size"]}</td><td>#{r["array"][0]["used"]}</td></td>"
      end
      table << "</table>"
    end
    
  end
  
  helpers DataHelpers
  helpers MongoHelpers
end
