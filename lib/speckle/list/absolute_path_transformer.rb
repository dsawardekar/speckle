module Speckle
  module List
    class AbsolutePathTransformer
      def run(item)
        [File.absolute_path(item)]
      end
    end
  end
end
