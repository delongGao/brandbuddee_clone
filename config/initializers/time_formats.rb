# config/initializers/time_formats.rb
Time::DATE_FORMATS[:time_date] = "%I:%M%p on %b %d '%y"
Time::DATE_FORMATS[:time] = "%I:%M"
Time::DATE_FORMATS[:hour] = "%H"
Time::DATE_FORMATS[:min] = "%M"
Time::DATE_FORMATS[:ampm] = "%p"
Time::DATE_FORMATS[:date] = "%d %b"
Time::DATE_FORMATS[:month] = "%m"
Time::DATE_FORMATS[:day] = "%d"
Time::DATE_FORMATS[:year] = "%Y"
Time::DATE_FORMATS[:short_year] = "%y"
Time::DATE_FORMATS[:month_and_year] = "%B %Y"
Time::DATE_FORMATS[:short_ordinal] = lambda { |time| time.strftime("%B #{time.day.ordinalize}") }