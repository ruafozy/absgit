def with_bundler(*command)
  command.tap do |cmd|
    if !ENV.has_key?('BUNDLE_BIN_PATH')
      cmd.unshift('bundle', 'exec') 
    end
  end
end
