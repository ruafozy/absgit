require 'fileutils'
require 'shellwords'
require 'tmpdir'

module AbsgitCommon
  APP_PATH = File.expand_path(
    "../../../bin/#{Absgit::PROGRAM_NAME}",
    __FILE__
  )
  APP_PATH_ESC = Shellwords.escape(APP_PATH)

  def setup
    @saved_dir = Dir.pwd

    @temp_dir = Dir.mktmpdir

    Dir.chdir(@temp_dir)
  end

  def teardown
    Dir.chdir(@saved_dir)

    FileUtils.rm_r(@temp_dir, secure: true)
  end

  private

  def files_in_index(repo)
    Dir.chdir(repo) do
      %x{git ls-files}.split("\n")
    end
  end

  def num_commits(repo_dir)
    Dir.chdir(repo_dir) {
      `git rev-list --count HEAD`.match(/\A\d+\n\z/) { |m|
        m[0].to_i
      }
    }
  end

  def get_repo
    dir = Dir.mktmpdir(nil, '.')
    system('git', 'init', '--quiet', dir)
    dir
  end
end

0.times do
  module Kernel
    alias old_system system

    def system(*a)
      puts "\ndebug: about to call #{__method__} with " +
        "these parameters: #{a.inspect}"
      old_system(*a)
      puts "\ndebug: call to #{__method__} completed"
    end
  end
end
