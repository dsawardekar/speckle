module Speckle
  module List
    class ExtensionTransformer
      def initialize(extension)
        @extension = extension
      end

      def run(item)
        item = item.ext(@extension)
        return [item]
      end
    end
  end
end
