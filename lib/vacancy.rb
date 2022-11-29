class Vacancy
  # duration is in hours
  attr_reader :date, :start_time, :end_time, :duration, :court_info

  def initialize(date:, start_time:, end_time:, court_info:)
    @date = date
    @start_time = start_time
    @end_time = end_time
    @duration = ((end_time - start_time) / 3600.0).round(1)
    @court_info = court_info
  end

  # "Tue Nov 29, 2022 08:00 AM  - 09:00 AM (1h) Court 1"
  def to_s
    [
      date.strftime('%a %b %d, %Y'),
      start_time.strftime('%I:%M %p'),
      '-',
      end_time.strftime('%I:%M %p'),
      "(#{duration}h)",
      court_info
    ].join(' ')
  end

  def to_h
    {
      date: date.strftime('%a %b %d, %Y'),
      start_time: start_time.strftime('%I:%M %p'),
      end_time: end_time.strftime('%I:%M %p'),
      duration: "#{duration}h",
      court_info:
    }
  end
end
