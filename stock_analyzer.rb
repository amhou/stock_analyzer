require 'json'
require 'httparty'

class StockAnalyzer
  BEGIN_DATE = Date.new(2017,01,01)
  END_DATE = Date.new(2017,06,30)
  TICKER_SYMBOLS = ["COF", "GOOGL", "MSFT"]

  BUSY_THRESHOLD = 1.1 # We consider a day busy if the volume is 10% higher than the average volume

  QUANDL_API_KEY = "s-GMZ_xkw6CrkGYUWs1p".freeze
  QUANDL_ENDPOINT = "https://www.quandl.com/api/v3/datatables/WIKI/PRICES.json?"\
                    "date.gte=#{BEGIN_DATE.strftime("%Y%m%d")}&"\
                    "date.lte=#{END_DATE.strftime("%Y%m%d")}&"\
                    "ticker=#{TICKER_SYMBOLS.join(",")}&"\
                    "api_key=#{QUANDL_API_KEY}"

  # Get the aggregate average open and close price for all our stick tickers.
  def ticker_analysis_average_open_and_close
    analysis_result = {}

    TICKER_SYMBOLS.each do |ticker|
      # Get the data for each ticker symbol
      analysis_result[ticker] = average_monthly_open_and_close(ticker)
    end

    return analysis_result
  end

  # Get the aggregate max daily profit for all our stock tickers.
  def ticker_analysis_max_daily_profit
    analysis_result = {}

    TICKER_SYMBOLS.each do |ticker|
      # Get the data for each ticker symbol
      analysis_result[ticker] = max_daily_profit(ticker)
    end

    return analysis_result
  end

  # Get the aggregate busy days for all our stock tickers.
  def ticker_analysis_busy_days
    analysis_result = {}

    TICKER_SYMBOLS.each do |ticker|
      # Get the data for each ticker symbol
      analysis_result[ticker] = busy_days(ticker)
    end

    return analysis_result
  end

  # Get the security that had the largest number of days where the closing price was lower than the opening price.
  #
  # Returns:
  # {
  #   "biggest_loser": <some_ticker>,
  #   "losing_days": <some_count>
  # }
  def ticker_analysis_biggest_loser
    losers = {}

    TICKER_SYMBOLS.each do |ticker|
      losers[ticker] = losing_days(ticker)
    end

    losing_days = 0
    losing_ticker = ""

    losers.each do |k,v|
      if losing_days < v
        losing_ticker = k
        losing_days = v
      end
    end

    return {
      "biggest_loser" => losing_ticker,
      "losing_days" => losing_days
    }
  end


  private

  # Get the average open and close price for a given stock ticker.
  # Returns an array in the given format:
  # [
  #   {
  #     "month": <yyyy-mm>,
  #     "average_open": <some_price>,
  #     "average_close": <some_price>,
  #   },
  #   ...
  # ]
  def average_monthly_open_and_close(ticker)
    result = []

    # Select all the data for the given ticker
    ticker_data = raw_stock_data_for_ticker(ticker)

    month_to_consider = BEGIN_DATE

    while month_to_consider < END_DATE
      data_for_month = ticker_data.select { |r| r[1].start_with?(month_to_consider.strftime("%Y-%m")) }

      # Transpose the array ond sum up the elements at the columns we're interested in
      open_prices = data_for_month.transpose[2]
      average_open = open_prices.nil? ? 0 : ( open_prices.reduce(:+) / data_for_month.length ).round(2) # Because float

      close_prices = data_for_month.transpose[5]
      average_close = close_prices.nil? ? 0 : ( close_prices.reduce(:+) / data_for_month.length ).round(2) # Because float

      result << {
        "month" => month_to_consider.strftime("%Y-%m"),
        "average_open" => average_open,
        "average_close" => average_close
      }

      # Increment to the next month
      month_to_consider = month_to_consider.next_month
    end

    return result
  end

  # Get the max daily profit possible over our given date range.
  #
  # Returns a hash in the given format:
  # {
  #   "date": <some_date>,
  #   "max_profit": <some_profit>,
  #   "low": <some_price>,
  #   "high": <some_price>
  # }
  def max_daily_profit(ticker)
    ticker_data = raw_stock_data_for_ticker(ticker)

    result = {
      "date" => "",
      "max_profit" => 0,
      "low" => 0,
      "high" => 0,
    }

    ticker_data.each do |t|
      date = t[1]
      daily_high = t[3]
      daily_low = t[4]

      daily_profit = (daily_high - daily_low).round(2) # Because float

      if daily_profit > result['max_profit']
        result['max_profit'] = daily_profit
        result['date'] = date
        result['low'] = daily_low
        result['high'] = daily_high
      end
    end

    return result
  end

  # Get the dates that provided unusually high activity.
  # "High activity" is defined as any volume that was 10% higher than the ticker's average volume.
  #
  # Returns:
  # [
  #   {
  #     "date": <some_date>,
  #     "volume": <some_volume>,
  #     "average_volume": <some_volume>
  #   },
  #   ...
  # ]
  def busy_days(ticker)
    _busy_days = []

    # Select all the data for the given ticker
    ticker_data = raw_stock_data_for_ticker(ticker)

    # Transpose the array ond sum up the elements at the columns we're interested in
    average_volume = (ticker_data.transpose[6].reduce(:+) / ticker_data.length).round(2) # Because float

    ticker_data.each do |t|
      date = t[1]
      volume = t[6]

      if ( volume / average_volume ) > BUSY_THRESHOLD
        _busy_days << {
          'date' => date,
          'volume' => volume.round(2) # Because float
        }
      end
    end

    return {
      "average_volume" => average_volume,
      "busy_days" => _busy_days
    }
  end

  # Get the number of days the given ticker's closing price was lower than the opening price.
  #
  # Returns an Integer.
  def losing_days(ticker)
    _losing_days = 0

    # Select all the data for the given ticker
    ticker_data = raw_stock_data_for_ticker(ticker)

    ticker_data.each do |t|
      open_price = t[2]
      close_price = t[5]

      if close_price < open_price
        _losing_days += 1
      end
    end

    return _losing_days
  end

  # Get the raw stock data for a given ticker
  def raw_stock_data_for_ticker(ticker)
    all_ticker_data = raw_stock_data.select { |r| r[0] == ticker }
  end

  # Get the raw data for all our stocks from Quandl WIKI.
  # The data is returned in an array of arrays, where each row represents a single date's data.
  # E.g.
  #   ["FB", "2015-12-31", 106.0, 106.17, 104.62, 104.66, 18391064.0, 0.0, 1.0, 106.0, 106.17, 104.62, 104.66, 18391064.0]
  #
  # Where the columns are:
  #   ["ticker", "date", "open", "high", "low", "close", "volume", "ex-dividend",
  #    "split_ratio", "adj_open", "adj_high", "adj_low", "adj_close", "adj_volume"]
  def raw_stock_data
    return @raw_stock_data unless @raw_stock_data.nil?

    raw_response = JSON.load(HTTParty.get(QUANDL_ENDPOINT).body)
    @raw_stock_data = raw_response['datatable']['data']
  end
end
