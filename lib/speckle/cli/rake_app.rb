module Speckle
  module CLI

    require 'rake'

    class RakeApp
      def initialize(options)
        @options = options
      end

      def inputs
        @options.inputs
      end

      def verbose
        @options.verbose
      end

      def debug
        @options.debug
      end 

      def rake
        if @rake_app
          return @rake_app
        end

        configure_rake
        Dir.chdir @options.root_dir

        @rake_app = Rake.application
        @rake_app.init
        @rake_app.load_rakefile

        Dir.chdir @options.cwd
        @rake_app
      end

      def invoke_task(name)
        rake.invoke_task("speckle:#{name.to_s}")
      end

      def rake_env(key, value)
        unless value.nil?
          ENV[key] = if value.is_a?(Array) then value.join(';') else value end
          puts "rake_env: #{key} = #{ENV[key]}" if debug
        end
      end 

      def configure_rake
        rake_env('TEST_SOURCES', test_sources)
        rake_env('TEST_LIBS', test_libs)
        rake_env('BUILD_DIR', test_build_dir)
        rake_env('TEST_COMPILED', test_compiled)
        rake_env('TEST_VIM', @options.vim)
        rake_env('TEST_REPORTER', @options.reporter)
        rake_env('SLOW_THRESHOLD', @options.slow_threshold.to_s)
        rake_env('SKIP_VIMRC', to_int(@options.skip_vimrc))
        rake_env('COLORIZE', to_int(@options.colorize))
        rake_env('BAIL', to_int(@options.bail))
        rake_env('TAG', @options.tag)

        if @options.verbose
          rake_env('VERBOSE', 'yes')
        end

        if @options.debug
          rake_env('DEBUG', 'yes')
        end
      end

      def to_int(option)
        option ? '1' : '0'
      end

      def test_build_dir
        "#{@options.cwd}/build"
      end

      def test_compiled
        compiled = test_sources.map do |s|
          s.ext('vim')
        end

        compiled
      end

      def test_sources
        sources = []
        grep_pattern = @options.grep_pattern
        grep_invert = @options.grep_invert
        unless grep_pattern.nil?
          regex = Regexp.new(grep_pattern)
        end

        inputs.each do |input|
          if File.directory?(input)
            if grep_pattern.nil?
              sources << "#{input}/**/*_spec.riml"
            else
              sources = Dir.glob("#{input}/**/*_spec.riml")
              sources.keep_if do |source|
                matched = regex.match(source)
                if grep_invert
                  matched = !matched
                end

                matched
              end
            end
          else
            if grep_pattern.nil?
              sources << input
            else
              matched = regex.match(input)
              if grep_invert
                matched = !matched
              end
              sources << input if matched
            end
          end
        end

        sources
      end

      def test_libs
        input_libs = @options.libs
        return nil if input_libs.nil?

        input_libs = input_libs.split(':')
        input_libs << 'spec'
        if File.directory?(@options.speckle_lib_dir)
          input_libs << @options.speckle_lib_dir
        end

        libs = []
        input_libs.each do |lib|
          libs << File.absolute_path(lib)
        end

        libs.join(':')
      end

    end
  end
end
