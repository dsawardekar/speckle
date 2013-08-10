module Speckle

  module CLI

    require 'optparse'
    require 'ostruct'

    class Environment
      include Loader

      def load(args)
        options = OpenStruct.new
        options.libs = nil
        options.grep_pattern = nil
        options.grep_invert = false
        options.reporter = 'dot'
        options.args = args
        options.verbose = false
        options.vim = 'vim'
        options.cwd = Dir.pwd
        options.root_dir = ROOT_DIR
        options.speckle_build_dir = "#{ROOT_DIR}/build"
        options.speckle_lib_dir = "#{ROOT_DIR}/lib"
        options.skip_vimrc = false
        options.slow_threshold = 10
        options.colorize = true
        options.bail = false
        options.tag = nil

        parser = OptionParser.new do |opts|
          options.opts = opts

          opts.banner = "Usage: speckle [options] [file(s) OR directory]"
          opts.separator ''
          opts.separator 'Options:'
          opts.separator ''

          opts.on_head('-c', '--compile', 'Only compile tests') do
            options.action = :compile
          end

          opts.on_head('-t', '--test', 'Only run tests') do
            options.action = :test
          end

          opts.on_head('-a', '--all', 'Compile and run tests (default)') do
            options.action = :compile_and_test
          end

          opts.on('-I', '--libs <libs>', 'Specify additional riml library path(s)') do |libs|
            options.libs = libs
          end

          opts.on('-g', '--grep <pattern>', 'Only run tests matching the pattern') do |pattern|
            options.grep_pattern = pattern.strip
          end

          opts.on('-i', '--invert', 'Inverts --grep matches') do
            options.grep_invert = true
          end

          opts.on('--tag <tag>', 'Only run tests matching tag') do |tag|
            options.tag = tag
          end

          opts.on('-r', '--reporter <reporter>', 'Specify the reporter to use (spec, min, dot, tap)') do |reporter|
            options.reporter = reporter.strip
          end

          opts.on('-b', '--bail', 'Bail on first test failure') do
            options.bail = true
          end

          opts.on('-w', '--watch', 'Watch tests for changes') do
            options.action = :watch
          end

          opts.on('-m', '--vim <vim>', 'Vim program used to test, default(vim)') do |vim|
            options.vim = vim.strip
          end

          opts.on('-s', '--slow-threshold <ms>', Integer, 'Threshold in milliseconds to indicate slow tests') do |ms|
            options.slow_threshold = ms
          end

          opts.on('-k', '--skip-vimrc', 'Does not load ~/.vimrc file') do
            options.skip_vimrc = true
          end

          opts.on('-C', '--no-colors', 'Disable color output') do
            options.colorize = false
          end

          opts.on('-v', '--verbose', 'Display verbose output') do
            options.verbose = true
          end
          
          opts.on('-D', '--debug', 'Display debug output') do
            options.verbose = true
            options.debug = true
          end

          opts.on_tail('-V', '--version', 'Print Speckle version') do
            options.action = :show_version
          end

          opts.on_tail('-h', '--help', 'Print Speckle help') do
            options.action = :show_help
          end
        end

        begin
          parser.parse!(args)

          if options.action.nil?
            spec_dir = "#{options.cwd}/spec"
            if File.directory?(spec_dir)
              args << 'spec'
              options.action = :compile_and_test
            else
              options.action = :show_no_spec_dir
            end
          elsif action_needs_args?(options.action) and args.empty?
            spec_dir = "#{options.cwd}/spec"
            if File.directory?(spec_dir)
              args << 'spec'
              options.action = :compile_and_test
            end
          end

          options.inputs = args
        rescue OptionParser::InvalidOption => e
          options.error = e
          options.action = :show_invalid_option
        rescue OptionParser::MissingArgument => e
          options.error = e
          options.action = :show_missing_args
        rescue OptionParser::ParseError => e
          options.error = e
          options.action = :show_parser_error
        end

        options
      end

      def action_needs_args?(action)
        [:compile_and_test, :compile, :test].include? action
      end
    end


  end
end
