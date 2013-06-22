require 'bundler/gem_tasks'

desc 'Run absgit'
task :run, [:absgit_args] do |dummy, args|
  system(
    *with_bundler(
      'ruby', '-I', 'lib', 'bin/absgit', *args.absgit_args.split
    )
  )
end

desc %q{Run the test suite (`pat' is used with "-n")}
task :test, [:pat] do |dummy, args|
  cmd = 'minitest4', '-p', 'test', '--', '-v'

  if args.pat
    cmd += ['-n', args.pat]
  end

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
