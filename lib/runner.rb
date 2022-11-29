class Runner
  # config contains a mapping between court and scaper
  # eg.
  #
  # Runner.new(
  #   btc: BTCScraper.new,
  #   ubc: UBCScraper.new,
  # )
  def initialize(venue_scraper = {})
    @venues = load_venues
    @venue_scraper = venue_scraper
  end

  def run
    vacancies = []
    @venue_scraper.each do |_venue, scraper|
      vacancies << scraper.run
    end
  end

  private

  def load_venues
    venues = {}
    JSON.parse(File.read('./venues.json')).each do |id, venue|
      venues[id] = OpenStruct.new(venue)
    end
    venues
  end
end
