require 'absgit'
require 'absgit_common'
require 'minitest/unit'

class AbsgitWithinRepoTest < MiniTest::Unit::TestCase
  include AbsgitCommon

  def setup
    super
    Dir.chdir(get_repo)
  end

  def test_exit_status_preserved
    [
      %w{ls-files},
      %w{ls-files --non-existent-option},
      %w{add non-existent-file},
    ].each do |args|
      # Given & When

      opts = {
        err: '/dev/null',
        out: '/dev/null',
      }
      system(*(%w{git} + args), opts)
      git_exit_status = $?.exitstatus
      system(*([APP_PATH] + args), opts)
      absgit_exit_status = $?.exitstatus

      # Then

      assert_equal(git_exit_status, absgit_exit_status)
    end
  end
end
