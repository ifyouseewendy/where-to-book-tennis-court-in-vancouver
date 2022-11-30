require 'json'

module VENUES
  RAW = File.expand_path('../venues.json', __dir__)

  def self.at(id)
    all[id.to_s]
  end

  def self.all
    @venues ||= JSON.parse(File.read(RAW)).each_with_object({}) do |venue, h|
      h[venue['id']] = venue
    end
  end
end
