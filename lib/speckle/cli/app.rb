module Speckle
  module CLI

    require_relative 'environment'
    require_relative 'router'
    
    class App
      def start(args)
        env = Environment.new
        options = env.load(args)

        router = Router.new
        router.route(options.action, options)
      end
    end

  end
end
