require 'spec_helper'
require 'speckle/cli/environment'

RSpec::Matchers.define :yield_action do |expected|
  match do |actual|
    env = Speckle::CLI::Environment.new
    @options = env.load(actual.kind_of?(Array) ? actual : [actual])
    @options.action == expected
  end

  failure_message_for_should do |actual|
    "expected #{actual} to yield action :#{expected.to_s} but was :#{@options.action}"
  end

  failure_message_for_should_not do |actual|
    "expected #{actual} to not yield action :#{expected.to_s} but was :#{@options.action}"
  end
end

RSpec::Matchers.define :yield_option do |expected|
  match do |actual|
    env = Speckle::CLI::Environment.new
    @options = env.load(actual.kind_of?(Array) ? actual : [actual])
    @result = @options.send(expected)
    @result == true
  end

  failure_message_for_should do |actual|
    "expected #{actual} to yield option :#{expected.to_s}, but was #{@result}"
  end

  failure_message_for_should_not do |*args|
    "expected #{actual} to not yield option :#{expected.to_s}, but was #{@result}"
  end
end

RSpec::Matchers.define :have_default_option do |expected|
  match do |actual|
    env = Speckle::CLI::Environment.new
    @options = env.load(actual.kind_of?(Array) ? actual : [actual])
    @options.send(expected) == true
  end

  failure_message_for_should do |actual|
    "expected #{actual} to have default option :#{expected.to_s}"
  end

  failure_message_for_should_not do |actual|
    "expected #{actual} to not have default option :#{expected.to_s}"
  end
end

RSpec::Matchers.define :have_default_option_value do |key, value|
  match do |actual|
    env = Speckle::CLI::Environment.new
    @options = env.load(actual.kind_of?(Array) ? actual : [actual])
    @result = @options.send(key)
    @result == value
  end

  failure_message_for_should do |actual|
    "expected #{actual} to have default option #{key} = #{value}, but was #{@result}"
  end

  failure_message_for_should_not do |*args|
    "expected #{actual} to not have default option #{key} = #{value}, but was #{@result}"
  end
end

RSpec::Matchers.define :yield_option_value do |key, value|
  match do |actual|
    env = Speckle::CLI::Environment.new
    @options = env.load(actual.kind_of?(Array) ? actual : [actual])
    @result = @options.send(key)
    @result == value
  end

  failure_message_for_should do |actual|
    "expected #{actual} to yield option #{key} = #{value} but was '#{@result}'"
  end

  failure_message_for_should_not do |actual|
    "expected #{actual} to not yield option #{key} = #{value} but was #{options.send(key)}"
  end
end

RSpec::Matchers.define :include_path do |expected|
  match do |actual|
    env = Speckle::CLI::Environment.new
    @options = env.load(actual.kind_of?(Array) ? actual : [actual])
    @result = @options.inputs
    @result.include?(expected)
  end

  failure_message_for_should do |actual|
    "expected #{actual} to include path #{expected}, inputs was #{@result}"
  end

  failure_message_for_should_not do |actual|
    "expected #{actual} to not include path #{actual}, inputs was #{@result}"
  end
end

module Speckle
  module CLI

    describe 'Main options basics' do

      it 'defaults to compile_and_test without args' do
        expect('').to yield_action(:compile_and_test)
      end

      it 'has action :compile_and_test with -a or --all' do
        expect(['-a', 'foo']).to yield_action :compile_and_test
        expect(['--all', 'foo']).to yield_action :compile_and_test
      end

      it 'has action :compile with -c or --compile' do
        expect(['-c', 'foo']).to yield_action :compile
        expect(['--compile', 'foo']).to yield_action :compile
      end

      it 'has action :test with -t or --test' do
        expect(['-t', 'foo']).to yield_action :test
        expect(['--test', 'foo']).to yield_action :test
      end

    end

    describe 'Source path defaults' do

      it 'uses spec directory without args', :dms => true do
        expect('').to include_path('spec')
      end

      it 'includes spec directory if no files were specified with -a or --all' do
        expect('-a').to include_path('spec')
        expect('--all').to include_path('spec')
      end

      it 'includes spec directory if no files were specified with -c or --compile' do
        expect('-c').to include_path('spec')
        expect('--compile').to include_path('spec')
      end

      it 'includes spec directory if no files were specified with -t or --test' do
        expect('-t').to include_path('spec')
        expect('--test').to include_path('spec')
      end

      it 'does not use spec directory when file is specified', :dms => true do
        expect('a.riml').to include_path('a.riml')
        expect('a.riml').to_not include_path('spec')
      end

      it 'does not use spec directory when multiple file is specified', :dms => true do
        env = Environment.new
        opts = env.load(['a.riml', 'b.riml'])
        expect(opts.inputs).to eq(['a.riml', 'b.riml'])
      end
    end

    describe 'Extra options and flags' do

      it 'can load args' do
        env = Environment.new
        expect(env).to respond_to(:load)
      end

      it 'has :show_help action for -h or --help' do
        expect('-h').to yield_action(:show_help)
        expect('--help').to yield_action(:show_help)
      end

      it 'has :show_version action for -V or --version' do
        expect('-V').to yield_action :show_version
        expect('--version').to yield_action :show_version
      end

      it 'has verbose flag for -v or --verbose' do
        expect('-v').to yield_option 'verbose'
        expect('--verbose').to yield_option 'verbose'
      end

      it 'has debug flag for -D or --debug' do
        expect('-D').to yield_option 'debug'
        expect('--debug').to yield_option 'debug'
      end

      it 'does not have colorize flag for -C or --no-colors' do
        expect('-C').to_not yield_option 'colorize'
        expect('--no-colors').to_not yield_option 'colorize'
      end

      it 'has colorize by default' do
        expect('').to have_default_option 'colorize'
      end

      it 'has does not skip vimrc by default' do
        expect('').to_not have_default_option 'skip_vimrc'
      end

      it 'does not have skip_vimrc for -k or --skip-vimrc' do
        expect('-k').to yield_option 'skip_vimrc'
        expect('--skip-vimrc').to yield_option 'skip_vimrc'
      end

      it 'has :watch action for -w or --watch' do
        expect('-w').to yield_action :watch
        expect('--watch').to yield_action :watch
      end

      it 'bail by default' do
        expect('').to_not have_default_option 'bail'
      end

      it 'has bail option by default' do
        expect('-b').to yield_option 'bail'
        expect('--bail').to yield_option 'bail'
      end

      it 'has default vim program' do
        expect('').to have_default_option_value('vim', 'vim')
      end

      it 'takes specified vim program for -m or --vim' do
        expect(['-m', 'gvim']).to yield_option_value('vim', 'gvim')
        expect(['--vim', 'gvim']).to yield_option_value('vim', 'gvim')
      end

      it 'has a default slow threshold' do
        expect('').to have_default_option_value('slow_threshold', 10)
      end

      it 'takes slow_threshold for -k or --slow-threshold' do
        expect(['-s', '10']).to yield_option_value('slow_threshold', 10)
        expect(['--slow-threshold', '10']).to yield_option_value('slow_threshold', 10)
      end

      it 'does not have default grep pattern' do
        expect('').to_not have_default_option('grep_pattern')
      end

      it 'takes grep pattern for -g or --grep' do
        expect(['-g', '^foo']).to yield_option_value('grep_pattern', '^foo')
        expect(['--grep', '^foo']).to yield_option_value('grep_pattern', '^foo')
      end

      it 'does not have default invert grep pattern' do
        expect('').to_not have_default_option('grep_invert')
      end

      it 'takes invert grep pattern for -i or --invert' do
        expect('-i').to yield_option('grep_invert')
        expect('--invert').to yield_option('grep_invert')
      end

      it 'takes libs from -I or --libs' do
        expect(['-I', 'lorem:ipsum:dolor']).to yield_option_value('libs', 'lorem:ipsum:dolor')
      end

      it 'has a default reporter' do
        expect('').to have_default_option_value('reporter', 'dot')
      end

      it 'takes reporter from -r or --reporter' do
        expect(['-r', 'min']).to yield_option_value('reporter', 'min')
        expect(['--reporter', 'min']).to yield_option_value('reporter', 'min')
      end

      it 'does not have tag by default' do
        expect('').to_not have_default_option('tag')
      end

      it 'takes tag from --tag' do
        expect(['--tag', 'focus']).to yield_option_value('tag', 'focus')
      end

      it 'does not have duplicate inputs', :foo => true do
        env = Environment.new
        opts = env.load(['spec', 'spec'])
        expect(opts.inputs.length).to eq(1)
      end

    end

    describe 'Complete CLI options' do
      def env(*args)
        env = Environment.new
        env.load(args)
      end

      it 'works with example#1' do
        opts = env('-a', 'foo', '-I', 'lorem:ipsum', '-r', 'min', '-C', '-D')
        expect(opts.action).to eq(:compile_and_test)
        expect(opts.inputs).to include('foo')
        expect(opts.libs).to eq('lorem:ipsum')
        expect(opts.reporter).to eq('min')
        expect(opts.debug).to eq(true)
      end

      it 'works with example#2' do
        opts = env('foo', '-r', 'dot', '-I', 'lorem:ipsum', '-v')
        expect(opts.action).to eq(:compile_and_test)
        expect(opts.inputs).to include('foo')
        expect(opts.libs).to eq('lorem:ipsum')
        expect(opts.reporter).to eq('dot')
        expect(opts.verbose).to eq(true)
      end

      it 'works with example#3' do
        opts = env('-r', 'tap', '-t', 'my_specs', '-I', 'stuff', '-D')
        expect(opts.action).to eq(:test)
        expect(opts.inputs).to include('my_specs')
        expect(opts.reporter).to eq('tap')
        expect(opts.libs).to eq('stuff')
      end

    end

  end
end
