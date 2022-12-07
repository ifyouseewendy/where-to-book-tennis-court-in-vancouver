# Where to book 🎾 court in Raincouver?

> Where can I book a freaking tennis court in Raincouver?
> -- Tennis Buddha

This project is to answer the universal question in one place.
To rephrase it, let's build a webpage to display the court vacancies in Vancouver.

## TODO

- [x] Parse booking page from [BTC](https://www.burnabytennis.ca/burnaby/home/readPage.do?id=141)
- [x] Parse booking page from [Coq - TTC](http://coquitlam.thetenniscentre.ca/)
- [x] Parse booking page from [Surrey - TTC](https://www.thetenniscentre.ca/surrey/book-court/)
- [x] Parse booking page from [Langley - TTC](https://www.thetenniscentre.ca/langley/book-court/)
- [x] Parse booking page from [Rmd - Hub](https://clubspark.ca/TBCHubRichmond/Booking/BookByDate)
- [ ] Parse booking page from UBC
- [x] Define a data storage format (JSON)
- [x] Build a HTML page to load data and render (mobile friendly)
- [x] Deploy somewhere and get HTML exposed
- [x] Add a background job to update data every five minutes
- [x] Erro handling
- [ ] Have cookies enabled for TEST
- [ ] Change name BTC to Btc

## Implementation notes

Generally

* `bin/run` is the script to scrape venue websites and store data into `runner-data.json`. It's configured to run every 5 minutes by Github Action
* `index.html` is the static page that loads and renders the data. It's hosted by Github Pages

More detail

* Data is actually stored in `runner-data.js` instead of `runner-data.json` to avoid CORS check, which requires JSON file to be loaded from a server.
* Data is mostly massaged in back end and served directly to front end.
* Data is sorted by `(date, start_time, end_time, court_info)`
* [mechanize](https://github.com/sparklemotion/mechanize) is the main scraping framework used.

### How to add a new venue

1. Add a new entry to `venues.json`
2. Add new scraper in `lib/new_venue_scraper.rb` with test `test/new_venue_scraper_test.rb`

### Known Issues

Github Actions

The shortest interval you can run scheduled workflows with Github Actions is once every 5 minutes.
But there is no guarantee on the frequency. In practice, I noticed it's around 10 minutes on average.

To scrape [Rmd - Hub](https://clubspark.ca/TBCHubRichmond/Booking/BookByDate)

There is an issue to log in this site, given it's using the [MS-MWBF](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-mwbf/4c34a083-81ec-4a20-b4fa-4b2481cdb6f6) sign-on protocal. After filling in user credentials and submitting, it returns back a page that contains a form with the security tokens and some javascript to submit the form. However, mechanize doesn't support JS running and I couldn't properly simulate the JS run. I end up not being able to figure out how to scrape the site.
