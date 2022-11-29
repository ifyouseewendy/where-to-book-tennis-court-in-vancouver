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

  # "Tue Nov 29, 2022 08:00 - 09:00 AM Court 1"
  def to_s
    [
      start_time.strftime('%a %b %d, %Y %I:%M'),
      '-',
      end_time.strftime('%I:%M %p'),
      court_info
    ].join(' ')
  end

  def to_h
    {
      date: @date.to_s,
      start_time: @start_time.strftime('%I:%M %p'),
      end_time: @end_time.strftime('%I:%M %p'),
      duration: "#{@duration}h",
      court_info: @court_info
    }
  end
end
