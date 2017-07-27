# stock_analyzer

Analyze GOOGL, MSFT, and COF.

```bash
$ /bin/stock_analysis.rb -h

Usage: stock_analysis.rb [options]
    -a, --analysis                   Analysis (Default)
    -m, --max-daily-profit           Max Daily Profit
    -b, --busy-day                   Busy Day
    -l, --biggest-loser              Biggest Loser
    -h, --help                       Print this help
```

Prints out the JSON value of any given stock analysis.

To run tests, simply execute:

```
bundle install
bundle exec rspec spec
```

Requires Ruby >2.3.x
