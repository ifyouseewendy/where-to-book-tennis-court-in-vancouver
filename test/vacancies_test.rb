require_relative './test_helper'

class VacanciesTest < Minitest::Test
  def setup
    @vacancies = Vacancies.new([
      { venue: :coq, date: Date.parse('2022-12-08'), start_time: Time.parse('2022-12-08 06:30 PM'),
        end_time: Time.parse('2022-12-08 09:30 PM'), duration: '3.0h', court_info: 'Court 5' },
      { venue: :coq, date: Date.parse('2022-12-08'), start_time: Time.parse('2022-12-08 09:30 PM'),
        end_time: Time.parse('2022-12-08 11:00 PM'), duration: '3.0h', court_info: 'Court 1' },
      { venue: :coq, date: Date.parse('2022-12-08'), start_time: Time.parse('2022-12-08 09:30 PM'),
        end_time: Time.parse('2022-12-08 11:00 PM'), duration: '3.0h', court_info: 'Court 2' },
      { venue: :coq, date: Date.parse('2022-12-08'), start_time: Time.parse('2022-12-08 09:30 PM'),
        end_time: Time.parse('2022-12-08 11:00 PM'), duration: '3.0h', court_info: 'Court 3' },
      { venue: :coq, date: Date.parse('2022-12-05'), start_time: Time.parse('2022-12-05 08:00 AM'),
        end_time: Time.parse('2022-12-05 08:30 AM'), duration: '0.5h', court_info: 'Court 02' },
      { venue: :coq, date: Date.parse('2022-12-05'), start_time: Time.parse('2022-12-05 08:00 AM'),
        end_time: Time.parse('2022-12-05 08:30 AM'), duration: '0.5h', court_info: 'Court 04' },
      { venue: :coq, date: Date.parse('2022-12-05'), start_time: Time.parse('2022-12-05 08:00 AM'),
        end_time: Time.parse('2022-12-05 09:30 AM'), duration: '1.5h', court_info: 'Court 3' }
    ].map { |h| Vacancy.new(**h) })
  end

  def test_sort_and_combine
    res = @vacancies.sort_and_combine
    expected = [{ venue: :coq, date: 'Mon Dec 05, 2022', start_time: '08:00 AM', end_time: '08:30 AM', duration: '0.5hh', court_info: 'Court 2, 4' },
                { venue: :coq, date: 'Mon Dec 05, 2022', start_time: '08:00 AM', end_time: '09:30 AM', duration: '1.5hh',
                  court_info: 'Court 3' },
                { venue: :coq, date: 'Thu Dec 08, 2022', start_time: '06:30 PM', end_time: '09:30 PM', duration: '3.0hh',
                  court_info: 'Court 5' },
                { venue: :coq, date: 'Thu Dec 08, 2022', start_time: '09:30 PM', end_time: '11:00 PM', duration: '3.0hh',
                  court_info: 'Court 1, 2, 3' }]
    assert_equal expected, res
  end
end
