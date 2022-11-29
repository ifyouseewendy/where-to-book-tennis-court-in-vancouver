require 'minitest/autorun'
require 'webmock/minitest'
require 'vcr'

require_relative '../lib/scraper'

VCR.configure do |config|
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :webmock
end
