module Speckle
  module List
    class DirExpander
      def initialize(pattern)
        @pattern = pattern
      end

      def run(item)
        pattern = "#{item}/#{@pattern}"
        #puts "DirExpander:run #{item}, pattern=#{pattern}"
        #puts "is dir = #{File.directory?(item)}"

        if File.directory?(item)
          return Dir.glob(pattern)
        else
          return [item]
        end
      end
    end
  end
end
