require 'absgit/version'
require 'methadone'
require 'optparse'
require 'pathname'
require 'utils'

class Absgit
  include Methadone::CLILogging
  include Utils

  GIT_DIR_BASE = '.git'
  PROGRAM_NAME = 'absgit'

  def initialize(args)
    @args = args.dup
    @options = {}
  end

  def self.get_repo_path(file_name)
    Pathname.new(file_name).ascend do |path|
      if path.exist?
        path.realpath.ascend do |path2|
          if (path2 + '.git').exist?
            return path2
          end
        end
      end
    end
  end

  def option_parser
    OptionParser.new do |parser|
      parser.program_name = PROGRAM_NAME
      parser.banner = "Usage: #{PROGRAM_NAME} [options] [GIT_SUBCOMMAND]"

      parser.on('--debug', 'Show debugging information') do
        @options[:debug] = true
      end

      parser.on('--help', 'Show this usage summary') do
        @options[:help] = true
      end

      parser.on(
        '-p', '--path PATH', 'Use PATH to determine Git repository'
      ) do |path|
        @options[:path] = path
      end

      parser.on('--version', 'Show program name and version') do
        @options[:version] = true
      end
    end
  end

  def run
    begin
      option_parser.order!(@args)
    rescue OptionParser::ParseError
      $stderr.puts 'Error: incorrect usage'
      $stderr.puts ''
      $stderr.puts option_parser
      exit(1)
    end

    if @options[:debug]
      logger.error_level = Logger::Severity::DEBUG
    end

    debug(@options.inspect)
    debug(@args.inspect)

    if @options[:version]
      puts "#{PROGRAM_NAME} #{VERSION}"
    elsif @options[:help]
      puts option_parser
    else
      if @options[:path]
        repo_path = self.class.get_repo_path(@options[:path])

        if repo_path.nil?
          $stderr.puts \
            "Fatal error: cannot " +
            "map path to Git repository: #{@options[:path]}"
          exit(1)
        end
      else
        repo_path =
          @args[1..-1].find_all { |arg| repo_object_candidate?(arg) }.
          each_with_object(nil) { |arg|
            repo = self.class.get_repo_path(arg)
            break repo if !repo.nil?
          }
      end

      if repo_path.nil?
        env = {}

        git_args = @args
      else
        env = {
          'GIT_DIR' => (repo_path + GIT_DIR_BASE).to_s,
          'GIT_WORK_TREE' => repo_path.to_s,
        }

        git_args = @args.map { |arg|
          make_tracked_files_relative_to_repo(repo_path, arg)
        }
      end

      command = ['git'] + git_args

      debug(command.inspect)
      debug(env.inspect)

      system(env, *command)
      #
      #< it seems better to use environment variables
      # rather than "--git-dir" and "--work-tree", because
      # environment variables will be inherited by processes
      # spawned by git aliases.

      exit($?.exited? ? $?.exitstatus: 1)
    end
  end

  private

  def repo_object_candidate?(arg)
    !!if arg.include?('/')
      path = Pathname.new(arg)
      path.exist? || path.dirname.exist?
    end
  end
end

# vim: set syntax=ruby:
