module Utils
  private

  def make_tracked_files_relative_to_repo(repo_dir, x)
    repo_dir_real = Pathname.new(repo_dir).realpath.to_s

    catch(:finished) do
      if x.include?('/')
        discards = []

        Pathname.new(x).ascend do |path|
          if path.exist?
            real = path.realpath.to_s

            if real == repo_dir_real ||
              real.start_with?(repo_dir_real + '/')
            then
              x = File.join(real, *discards)
              throw :finished
            end
          else
            discards.unshift(path.basename)
          end
        end
      end
    end

    x
  end
end
