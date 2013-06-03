require 'bundler/gem_tasks'

desc 'Run absgit'
task :run, [:absgit_args] do |dummy, args|
  system(
    *with_bundler(
      'ruby', '-I', 'lib', 'bin/absgit', *args.absgit_args.split
    )
  )
end

desc 'Run the test suite'
task :test do
  cmd = 'minitest4', 'test'
  cmd = 'minitest4', '-p', 'test', '--', '-v'

  #> we need to set RUBYLIB, because the test suite
  # invokes the application as a separate process

  system(
    {
      'RUBYLIB' =>
        (
          [
            File.join(__dir__, 'lib'),
            File.join(__dir__, 'test', 'lib'),
          ] +
          ENV.fetch('RUBYLIB', '').split(':')
        ).join(':')
    },
    *with_bundler(*cmd)
  )
end

task :default => :test
