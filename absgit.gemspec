# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'absgit/version'

Gem::Specification.new do |spec|
  spec.name          = "absgit"
  spec.version       = Absgit::VERSION
  spec.authors       = ["Ruafozy"]

  spec.summary   =
    %q{Allow manipulating Git repository files outside a repository}

  spec.description       = %q{
    This gem contains a program which allows one to
    manipulate files in a Git repository
    from any location in the filesystem.
  }.split.join(' ')

  spec.homepage      = "https://github.com/ruafozy/absgit"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)

  spec.required_ruby_version = '>= 2.0.0'

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{\Atest\z/})
  spec.require_paths = ["lib"]

  [
    ['methadone', ['~> 1.2.6']],
  ].each do |name, ver|
    spec.add_runtime_dependency(name, ver)
  end

  [
    ['bundler', ['~> 1.3']],
    ['minitest', ['~> 4.0']],
    ['minitest-reporters', ['~> 0.14.17']],
    ['rake'],
  ].each do |gem_info|
    spec.add_development_dependency(*gem_info)
  end

  #> there seems to be no way to specify in the gemspec
  # that rdoc documentation should not be generated.
  # see http://stackoverflow.com/q/16167876
  spec.has_rdoc = false
end
