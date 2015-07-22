require "rubygems"
begin
  require "rspec"
rescue LoadError
  require "spec"
end

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'etl'))
