require 'rubygems'
require 'bundler/setup'
require 'dotenv/load'
require 'minitest/autorun'
require 'webmock/minitest'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :webmock
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib/'))

require 'runner'
require 'venues'
