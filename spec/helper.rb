$:.unshift(File.expand_path('../../lib', __FILE__))

require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

require 'pathname'
require 'logger'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
log_path  = root_path.join('log')
log_path.mkpath

require 'adapter/spec/an_adapter'
require 'adapter/spec/marshal_adapter'
require 'adapter/spec/json_adapter'
require 'adapter/spec/types'

require 'support/module_helpers'

logger = Logger.new(log_path.join('test.log'))
LogBuddy.init(:logger => logger)

Rspec.configure do |c|
  c.include(ModuleHelpers)
end
