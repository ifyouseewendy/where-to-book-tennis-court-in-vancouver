class Vacancy
  include Comparable

  # duration is in hours
  attr_reader :venue, :date, :start_time, :end_time, :duration, :court_info

  def initialize(venue:, date:, start_time:, end_time:, court_info:, duration: nil)
    @venue = venue
    @date = date
    @start_time = start_time
    @end_time = end_time
    @duration = duration || ((end_time - start_time) / 3600.0).round(1)
    @court_info = court_info
  end

  # "Tue Nov 29, 2022 08:00 AM  - 09:00 AM (1h) Court 1"
  def to_s
    [
      "#{venue}:",
      date.strftime('%a %b %d, %Y'),
      start_time.strftime('%I:%M %p'),
      '-',
      end_time.strftime('%I:%M %p'),
      "(#{duration}h)",
      court_info
    ].join(' ')
  end

  def as_json
    {
      venue:,
      date: date.strftime('%a %b %d, %Y'),
      start_time: start_time.strftime('%I:%M %p'),
      end_time: end_time.strftime('%I:%M %p'),
      duration: "#{duration}h",
      court_info:
    }
  end

  def to_h
    {
      venue:,
      date:,
      start_time:,
      end_time:,
      duration:,
      court_info:
    }
  end

  def <=>(other)
    if date == other.date && start_time == other.start_time && end_time == other.end_time
      court_info <=> other.court_info
    elsif date == other.date && start_time == other.start_time
      end_time <=> other.end_time
    elsif date == other.date
      start_time <=> other.start_time
    else
      date <=> other.date
    end
  end
end
