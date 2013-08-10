module Speckle
  module CLI

    require_relative 'controller'

    class Router
      def route(action, options)
        controller = Controller.new(options)
        controller.send(action)
      end
    end

  end
end
