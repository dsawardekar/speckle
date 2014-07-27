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
  TEST_EXIT_FILE = "#{TEST_LOG}.exit"
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

  PROFILE = ENV.has_key?('PROFILE')
  PROFILE_PATH = "#{BUILD_DIR}/speckle.profile"

  if ENV.has_key?('RIML_DIR')
    RIML_EXEC = "#{ENV['RIML_DIR']}/bin/riml"
  else
    RIML_EXEC = "bundle exec riml"
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
      sh "#{RIML_EXEC} -c #{SPECKLE_SOURCE} -I #{SPECKLE_LIBS} -o #{SPECKLE_BUILD_DIR}"
    end

    verbose VERBOSE do
      sh "#{RIML_EXEC} -c #{SPECKLE_DSL_SOURCE} -o #{SPECKLE_BUILD_DIR}"
    end
  end

  task :scratch => [:build] do
    sh "#{RIML_EXEC} -c lib/scratch.riml -I #{SPECKLE_LIBS}"
  end

  desc "Compile specs"
  task :compile_tests => [:build] do
    compile_test_files(TEST_SOURCES, TEST_LIBS, BUILD_DIR)
    puts
  end

  def compile_test_files(files, libs, build_dir)
    if ENV.has_key?('RIML_DIR')
      require "#{ENV['RIML_DIR']}/lib/riml"
    else
      require 'riml'
    end

    opts = get_riml_opts(libs, build_dir)
    Riml::FileRollback.trap(:INT, :QUIT, :KILL) { $stderr.print("\n"); exit(1) }
    verbose true do
      Riml::FileRollback.guard do
        TEST_SOURCES.each do |t|
          puts "Compiling: #{t} "
          Riml.compile_files(t, opts)

          spec_dir = "#{BUILD_DIR}/#{File.dirname(t)}"
          verbose DEBUG do
            mkdir_p "#{spec_dir}"
            mv "#{BUILD_DIR}/#{File.basename(t).ext('vim')}", "#{spec_dir}"
          end
        end
      end
    end
  end

  def get_riml_opts(libs, build_dir)
    Riml.include_path = libs

    opts = {
      :readable => true,
      :output_dir => build_dir
    }

    return opts
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
      cmd += "-u NONE -i NONE --cmd ':set nocp | let g:speckle_nocp_mode = 1'"
    end

    cmd += " --cmd 'let g:speckle_mode = 1'"

    cmd
  end

  def launch_vim
    begin
      verbose DEBUG do
        launch_file = get_launch_cmd_file()
        File.delete(TEST_LOG) if File.exists?(TEST_LOG)
        File.delete(TEST_EXIT_FILE) if File.exists?(TEST_EXIT_FILE)
        File.delete(PROFILE_PATH) if File.exists?(PROFILE_PATH)

        sh "#{TEST_VIM} #{get_vim_options()} -S #{launch_file.path}"
        launch_file.unlink
        if File.exists?(TEST_EXIT_FILE)
          sh "cat #{TEST_LOG}"
          if PROFILE
            puts ''
            puts '------------------------------------------------------------------------------'
            puts "PROFILE SUMMARY"
            puts '------------------------------------------------------------------------------'
            puts ''
            print_profile
          end
          exit_code = File.read(TEST_EXIT_FILE)[0].to_i
          exit!(exit_code)
        else
          fail "Fatal error: #{TEST_LOG} not found."
        end
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
    launch_cmd = "source #{SPECKLE_OUTPUT}\n"

    if PROFILE
      launch_cmd += "profile start #{PROFILE_PATH}\n"
    end

    TEST_COMPILED.each do |t|
      if PROFILE
        launch_cmd += "profile! file #{t}\n"
      end
      launch_cmd += "source #{t}\n"
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
      launch_cmd += "let g:speckle_tag = '#{TAG}'\n"
    end

    if PROFILE
      launch_cmd += "let g:speckle_profile = 1\n"
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

  def print_profile
    can_print = false

    f = File.open(PROFILE_PATH)
    f.each do |line|
      if !can_print && line =~ /FUNCTIONS SORTED ON TOTAL TIME/
        can_print = true
      end
      if can_print
        puts line
      end
    end

    f.close
  end

end

