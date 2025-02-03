ENV['ENV'] = 'test'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib/'))
require 'boot'

require 'minitest/autorun'
require 'mocha/minitest'
require 'webmock/minitest'
require 'vcr'
require 'timecop'

VCR.configure do |config|
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :webmock
  config.ignore_localhost = true
end
