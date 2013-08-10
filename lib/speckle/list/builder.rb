module Speckle
  module List
    class Builder
      def initialize
        @sources = []
        @filters = []
        @filtered = nil
      end

      def add_source(source)
        @sources << source
      end

      def add_filter(filter)
        @filters << filter
      end

      def filter_list(list, filter)
        filtered = []
        list.each do |item|
          result = filter.run(item)
          filtered.concat(result)
        end

        filtered
      end

      def rebuild
        filtered = @sources
        @filters.each do |filter|
          filtered = filter_list(filtered, filter)
        end

        @filtered = filtered
      end

      def build
        rebuild if @filtered.nil?
        @filtered
      end
    end
  end
end
