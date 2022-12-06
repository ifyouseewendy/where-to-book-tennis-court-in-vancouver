# Where to book 🎾 court in Raincouver?

> Where can I book a freaking tennis court in Raincouver?
> -- Buddha

This project is to answer the universal question in one place.
To rephrase it, let's build a webpage to display the court vacancies.


## Note

Background job runs at `bin/run` for every X minutes. It dumps the data into `runner-data.json`, which then gets rendered by `index.html`.

Data is massaged mostly in server side and gets rendered directly in frontend.

## How to add a new venue

1. Add a new entry to `venues.json`
2. Add new scraper in `lib/new_venue_scraper.rb`
3. Add new test in `test/new_venue_scraper_test.rb`

## TODO

- [x] Parse booking page from [BTC](https://www.burnabytennis.ca/burnaby/home/readPage.do?id=141)
- [x] Parse booking page from [Coq - TTC](http://coquitlam.thetenniscentre.ca/)
- [x] Parse booking page from [Rmd - Hub](https://clubspark.ca/TBCHubRichmond/Booking/BookByDate)
- [ ] Parse booking page from UBC, Hub, Coquitlam tennis center
- [x] Define a data storage format (JSON)
- [x] Build a HTML page to load data and render (mobile friendly)
- [x] Deploy somewhere and get HTML exposed
- [x] Add a background job to update data every five minutes
- [x] Erro handling
- [ ] Have cookies enabled for TEST
- [ ] Change name BTC to Btc

