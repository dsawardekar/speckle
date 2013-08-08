module Speckle
  module CLI

    require_relative 'rake_app'
    require_relative 'controller'

    class Router
      def route(action, options)
        rake_app = RakeApp.new(options)
        controller = Controller.new(options, rake_app)
        controller.send(action)
      end
    end

  end
end
