require 'absgit'
require 'absgit_common'
require 'fileutils'
require 'shellwords'
require 'tmpdir'
require 'minitest/unit'

class AbsgitAboveRepoTest < MiniTest::Unit::TestCase
  include AbsgitCommon

  def test_help_message_is_output
    assert_match(/--help\b/, `#{APP_PATH_ESC} --help`)
  end

  def test_options_for_git_are_left_alone
    refute_match(
      /--help\b/,

      #> any program that consumes its input will do
      # instead of "wc"

      %x{
        PAGER=wc #{APP_PATH_ESC} log --help
      }
    )
  end

  def test_file_not_in_repo
    f = '/dev/null'

    if !File.exist?(f)
      skip
    else
      assert_nil(Absgit.get_repo_path(f))
    end
  end

  def test_symlinks_resolved
    # Given

    repo = 'a1/a2/a3/repo'
    repo_abs = File.absolute_path(repo)

    repo_file = File.join(repo, 'b1/b2/b3/file')
    repo_file_abs = File.absolute_path(repo_file)

    symlink = 'd/symlink'

    FileUtils.makedirs(File.dirname(repo_file))
    FileUtils.touch(repo_file)

    Dir.mkdir(File.dirname(symlink))
    File.symlink(repo_file_abs, symlink)

    system 'git', 'init', '--quiet', repo

    # When & Then

    assert_equal(repo_abs, Absgit.get_repo_path(symlink).to_s)
    assert_equal(
      repo_abs, Absgit.get_repo_path(File.absolute_path(symlink)).to_s
    )
  end

  def test_rel_path_works
    # Given

    repo = 'repo'
    Dir.mkdir(repo)
    system(*%W{git init --quiet #{repo}})
    filename = 'f'
    rel_path = File.join(repo, filename)
    FileUtils.touch(rel_path)

    # When

    system(APP_PATH, 'add', rel_path)

    # Then

    assert_equal(1, files_in_index(repo).size)
  end

  def test_symlink_works
    # Given

    repo = 'repo'
    Dir.mkdir(repo)
    system(*%W{git init --quiet #{repo}})
    filename = 'f'
    rel_path = File.join(repo, filename)
    FileUtils.touch(rel_path)
    symlink = './symlink'
    File.symlink(rel_path, symlink)

    # When

    system(APP_PATH, 'add', symlink)

    # Then

    assert_equal(1, files_in_index(repo).size)
  end

  def test_commit_does_not_require_chdir_to_repo
    # Given

    repo = 'repo'
    repo_file = File.join(repo, 'file')
    repo_file_abs = File.absolute_path(repo_file)

    Dir.mkdir(repo)
    system 'git', 'init', '--quiet', repo
    IO.write(repo_file, "blah\n")

    # When

    system(
      "#{APP_PATH_ESC} add #{repo_file_abs.shellescape}"
    )

    system(
      "#{APP_PATH_ESC} commit --quiet --message blah " +
        repo_file_abs.shellescape
    )

    # Then

    assert_equal(1, num_commits(repo))
  end

  def test_commit_works_for_removed_file
    # Given

    repo = 'repo'
    repo_file = File.join(repo, 'file')
    repo_file_abs = File.absolute_path(repo_file)

    Dir.mkdir(repo)
    system 'git', 'init', '--quiet', repo

    IO.write(repo_file, "blah\n")
    system(
      "#{APP_PATH_ESC} add #{repo_file_abs.shellescape}"
    )
    system(
      "#{APP_PATH_ESC} commit --quiet --message blah " +
        repo_file_abs.shellescape
    )

    num_commits_before = num_commits(repo)

    # When

    system(
      "#{APP_PATH_ESC} rm --quiet " +
        repo_file_abs.shellescape
    )
    system(
      "#{APP_PATH_ESC} commit --quiet --message blah " +
        repo_file_abs.shellescape
    )

    # Then

    assert_equal(num_commits_before + 1, num_commits(repo))
  end
end