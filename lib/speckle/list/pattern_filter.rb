module Speckle
  module List
    class PatternFilter
      def initialize(pattern, invert = false)
        @pattern = pattern
        @invert = invert
      end

      def run(item)
        regex = Regexp.new(@pattern)
        matched = !item.match(regex).nil?
        if @invert
          matched = !matched
        end

        return [item] if matched
        return []
      end
    end
  end
end
