module Speckle
  module List
    class FileContentFilter
      def initialize(pattern, invert = false)
        @pattern = pattern
        @invert = invert
      end

      def run(item)
        return [] unless File.exists?(item)

        matched = has_content(item, @pattern)
        if @invert
          matched = !matched
        end

        return [item] if matched
        return []
      end

      def has_content(item, pattern)
        regex = Regexp.new(pattern)
        File.readlines(item).grep(regex).size > 0
      end
    end
  end
end
