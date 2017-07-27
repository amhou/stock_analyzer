# stock_analyzer

Analyze GOOGL, MSFT, and COF.

Prints out the JSON value of any given stock analysis.

## Usage

Make sure to run `bundle install` first!

Then, from this directory,

```bash
$ ./bin/stock_analysis.rb -h

Usage: stock_analysis.rb [options]
    -a, --analysis                   Analysis (Default)
    -m, --max-daily-profit           Max Daily Profit
    -b, --busy-day                   Busy Day
    -l, --biggest-loser              Biggest Loser
    -h, --help                       Print this help
```

## Tests

To run tests, simply execute:

```
bundle install
bundle exec rspec spec
```

## Requirements

Ruby >2.3.x
