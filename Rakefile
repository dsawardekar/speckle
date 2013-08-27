require 'bundler/setup'
require 'bundler/gem_tasks'

desc 'Default task :compile_and_test'
task :default => :test

# We need the RSpec rake tasks to run spec
# but we don't want users of speckle to need rspec
# Eventually we want to switch from the cli calling
# the Rakefile to the Rakefile calling the cli.
begin
  # :spec task from rspec
  require 'rspec/core/rake_task'
  desc "Run speckle's rspec tests"
  RSpec::Core::RakeTask.new(:spec)

  desc 'Run rspec and speckle tests'
  task :test => [:spec, 'speckle:vim_version', 'speckle:compile_and_test']
rescue LoadError
  if ENV.has_key?('DEBUG')
    puts 'rspec/core/rake_task not found'
  end

  # no spec task in chain without rspec
  desc 'Run rspec and speckle tests'
  task :test => ['speckle:vim_version', 'speckle:compile_and_test']
end

desc 'Clean temporary files'
task :clean => ['speckle:clean']

desc 'Clobber temporary files'
task :clobber => ['speckle:clobber']

# speckle tasks
namespace :speckle do

  require 'rake/clean'
  require 'tempfile'

  # build paths
  BUILD_DIR      = ENV['BUILD_DIR'] || 'build'

  # misc config
  VERBOSE = ENV.has_key?('VERBOSE')
  DEBUG = ENV.has_key?('DEBUG')
  SLOW_THRESHOLD = ENV['SLOW_THRESHOLD'] || 10
  SKIP_VIMRC = ENV['SKIP_VIMRC'] == '1' || false
  COLORIZE = ENV['COLORIZE'] || 1
  BAIL = ENV['BAIL'] || 0
  TAG = ENV['TAG'] || false
  CI = ENV['CI'] || false

  # speckle sources
  SPECKLE_DIR = File.dirname(__FILE__)
  SPECKLE_BUILD_DIR = "#{SPECKLE_DIR}/build"
  LIB_DIR        = "#{SPECKLE_DIR}/lib"
  SPECKLE_LIBS = Dir.glob("#{LIB_DIR}/**/*").select { |f| File.directory? f }.push(LIB_DIR).join(':')
  SPECKLE_MAIN = 'speckle.riml'
  SPECKLE_SOURCE = "#{LIB_DIR}/#{SPECKLE_MAIN}"
  SPECKLE_TEMP_OUTPUT = "#{SPECKLE_MAIN}".ext('vim')
  SPECKLE_OUTPUT = "#{SPECKLE_BUILD_DIR}/#{SPECKLE_TEMP_OUTPUT}"
  SPECKLE_VIM = ENV['SPECKLE_VIM'] || SPECKLE_MAIN.ext('vim')

  SPECKLE_DSL = 'dsl.riml'
  SPECKLE_DSL_SOURCE = "#{LIB_DIR}/#{SPECKLE_DSL}"
  SPECKLE_DSL_TEMP_OUTPUT = "#{SPECKLE_DSL}".ext('vim')
  SPECKLE_DSL_OUTPUT = "#{SPECKLE_BUILD_DIR}/#{SPECKLE_DSL_TEMP_OUTPUT}"

  # clean
  CLEAN.include("#{BUILD_DIR}/**/*.vim")
  CLEAN.include("#{BUILD_DIR}/**/*.log")
  CLOBBER.include(BUILD_DIR)

  # test sources
  TEST_LIBS = ENV['TEST_LIBS'] || "spec:#{LIB_DIR}"
  TEST_VIM = ENV['TEST_VIM'] || 'vim'
  TEST_REPORTER = ENV['TEST_REPORTER'] || 'spec'
  TEST_LOG = "#{BUILD_DIR}/speckle.log"
  DEBUG_LOG = "#{BUILD_DIR}/debug.log"
  TEST_SOURCES  = FileList.new do |fl|
    sources = ENV['TEST_SOURCES']
    if sources
      sources = sources.split(';')
      sources.each do |s|
        fl.include(s)
      end
    else
      fl.include('spec/**/*_spec.riml')
    end
  end
  TEST_COMPILED = FileList.new do |fl|
    fl.exclude("#{SPECKLE_OUTPUT}")
    compiled = ENV['TEST_COMPILED']
    if compiled
      compiled = compiled.split(';')
      compiled.each do |c|
        fl.include("#{BUILD_DIR}/#{c}")
      end
    else
      fl.include("#{BUILD_DIR}/**/*.vim")
    end
  end

  desc 'All tasks'
  task :all => [:clean, :compile, :compile_tests, :test]

  desc 'Build files and folders'
  task :build do
    verbose DEBUG do
      mkdir_p BUILD_DIR
      mkdir_p SPECKLE_BUILD_DIR
    end
  end

  desc "Compile #{SPECKLE_MAIN}"
  task :compile => [:build] do
    puts "Compiling: #{SPECKLE_MAIN}"
    verbose VERBOSE do
      sh "bundle exec riml -c #{SPECKLE_SOURCE} -I #{SPECKLE_LIBS} -o #{SPECKLE_BUILD_DIR}"
    end

    verbose VERBOSE do
      sh "bundle exec riml -c #{SPECKLE_DSL_SOURCE} -o #{SPECKLE_BUILD_DIR}"
    end
  end

  task :scratch => [:build] do
    sh "bundle exec riml -c lib/scratch.riml -I #{SPECKLE_LIBS}"
  end

  desc "Compile specs"
  task :compile_tests => [:build] do
    TEST_SOURCES.each do |t|
      verbose VERBOSE do
        puts "Compiling: #{t} "
        sh "bundle exec riml -c #{t} -I #{TEST_LIBS} -o #{BUILD_DIR}"
      end

      spec_dir = "#{BUILD_DIR}/#{File.dirname(t)}"
      verbose DEBUG do
        mkdir_p "#{spec_dir}"
        mv "#{BUILD_DIR}/#{File.basename(t).ext('vim')}", "#{spec_dir}"
      end
    end

    puts
  end

  desc "Compile and test specs"
  task :compile_and_test => [:compile_tests] do
    verbose VERBOSE do
      Rake::Task['speckle:test'].invoke
    end
  end
  
  desc 'Shows vim --version'
  task :vim_version do
    if CI
      sh "#{TEST_VIM} --version"
    end
  end

  desc "Launch test runner"
  task :test do
    unless File.exists?(SPECKLE_OUTPUT)
      Rake::Task['speckle:compile'].invoke
    end

    puts 'Running tests: '
    puts

    if TEST_COMPILED.length > 0
      launch_vim
    elsif TAG
      puts "All tests were filtered out."
    else
      puts "No tests to run."
    end
  end

  desc "Watch files for changes and run tests"
  task :watch do 
    puts '--- TODO ---'
  end

  def get_vim_options
    cmd = ''
    if SKIP_VIMRC
      cmd += "-u NONE -i NONE"
    end

    cmd
  end

  def launch_vim
    begin
      verbose DEBUG do
        launch_file = get_launch_cmd_file()
        sh "#{TEST_VIM} #{get_vim_options()} -S #{launch_file.path}"
        sh "cat #{TEST_LOG}"
        launch_file.unlink
      end
    rescue RuntimeError => error
      puts error
      if DEBUG
        puts error.backtrace
      end
    end
  end

  # utils
  def get_launch_cmd_source
    launch_cmd = <<CMD
      source #{SPECKLE_OUTPUT}
CMD

    TEST_COMPILED.each do |t|
      launch_cmd += <<CMD
      source #{t}
CMD
    end

    launch_cmd += <<CMD
      let &verbosefile = '#{DEBUG_LOG}'
      let g:speckle_file_mode = 1
      let g:speckle_output_file = '#{TEST_LOG}'
      let g:speckle_reporter_name = '#{TEST_REPORTER}'
      let g:speckle_slow_threshold = #{SLOW_THRESHOLD}
      let g:speckle_colorize = #{COLORIZE}
      let g:speckle_bail = #{BAIL}
CMD
    if TAG
      launch_cmd += <<CMD
      let g:speckle_tag = '#{TAG}'
CMD
    end

    launch_cmd += <<CMD
      let speckle = g:SpeckleConstructor()
      :autocmd VimEnter * :call speckle.run()
      :q!
CMD

    if DEBUG
      puts launch_cmd
    end
    launch_cmd.gsub!(/([^\n])\n([^\n])/, '\1 | \2')
  end

  def get_launch_cmd_file
    cmd = get_launch_cmd_source
    file = Tempfile.new('speckle')
    file.write(cmd)
    file.close

    file
  end

end

