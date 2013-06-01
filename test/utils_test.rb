require 'fileutils'
require 'minitest/unit'
require 'tmpdir'
require 'utils'

class UtilsTest < MiniTest::Unit::TestCase
  include Utils

  def setup
    @saved_dir = Dir.pwd
    @temp_dir = Dir.mktmpdir
    Dir.chdir(@temp_dir)
  end

  def teardown
    Dir.chdir(@saved_dir)
    FileUtils.rm_r(@temp_dir, secure: true)
  end

  def test_make_tracked_files_relative_to_repo
    # Given

    name1 = 'a/b/c/d'
    FileUtils.makedirs(name1)

    symlink = 'a/b/c/symlink'
    File.symlink('d', symlink)

    name2 = "#{symlink}/e/f/g/h"

    # When

    result = make_tracked_files_relative_to_repo(name1, name2)

    # Then

    assert_equal(
      File.join(File.realpath(name1), 'e/f/g/h'),
      result
    )
  end
end
