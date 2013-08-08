module Speckle
  module CLI

    require 'speckle/version'

    class Controller

      def initialize(options, rake_app)
        @options = options
        @rake_app = rake_app
      end

      def rake(task)
        @rake_app.invoke_task(task)
      end

      def show_version
        puts VERSION
      end

      def show_help
        puts @options.opts
      end

      def show_error(msg = @options.error)
        puts "Error: #{msg}"
        puts

        show_help
      end

      def show_invalid_option
        show_error @options.error
      end

      def show_missing_args
        show_error @options.error
      end

      def show_parser_error
        show_error @options.error
      end

      def show_no_spec_dir
        show_error '"spec" directory not found'
      end

      def compile
        rake :compile_tests
      end

      def compile_and_test
        rake :compile_and_test
      end

      def test
        rake :test
      end

      def watch
        puts '--- TODO ---'
      end

    end

  end
end
