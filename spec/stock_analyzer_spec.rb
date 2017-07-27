require 'spec_helper'

describe StockAnalyzer do
  let(:subject) { StockAnalyzer.new }
  let(:data_for_ticker) {
    [
      ["STOCK", "2017-01-01", 100.0, 200.0, 0.0, 150.0, 12345.0, 0.0, 1.0, 100.0, 200.0, 0.0, 150.0, 12345.0],
      ["STOCK", "2017-01-02", 110.0, 210.0, 10.0, 160.0, 13579.0, 0.0, 1.0, 110.0, 210.0, 10.0, 160.0, 13579.0],
      ["STOCK", "2017-01-03", 120.0, 220.0, 20.0, 170.0, 12000.0, 0.0, 1.0, 120.0, 220.0, 20.0, 170.0, 12000.0],
    ]
  }

  describe "#ticker_analysis_average_open_and_close" do
    it "should call #average_monthly_open_and_close for every ticker" do
      expect(subject).to receive(:average_monthly_open_and_close).exactly(
        StockAnalyzer::TICKER_SYMBOLS.length
      ).times

      subject.ticker_analysis_average_open_and_close
    end
  end

  describe "#ticker_analysis_max_daily_profit" do
    it "should call #max_daily_profit for every ticker" do
      expect(subject).to receive(:max_daily_profit).exactly(
        StockAnalyzer::TICKER_SYMBOLS.length
      ).times

      subject.ticker_analysis_max_daily_profit
    end
  end

  describe "#ticker_analysis_busy_day" do
    it "should call #busy_days for every ticker" do
      expect(subject).to receive(:busy_days).exactly(
        StockAnalyzer::TICKER_SYMBOLS.length
      ).times

      subject.ticker_analysis_busy_days
    end
  end

  describe "#ticker_analysis_biggest_loser" do
    it "should call #losing_days for every ticker" do
      expect(subject).to receive(:losing_days).exactly(
        StockAnalyzer::TICKER_SYMBOLS.length
      ).times.and_return(0)

      subject.ticker_analysis_biggest_loser
    end

    it "should pick the losing-est stock" do
      allow(subject).to receive(:losing_days).with('COF').and_return(3)
      allow(subject).to receive(:losing_days).with('GOOGL').and_return(2)
      allow(subject).to receive(:losing_days).with('MSFT').and_return(1)

      expect(subject.ticker_analysis_biggest_loser).to eq({
        "biggest_loser" => 'COF',
        "losing_days" => 3
      })
    end
  end

  describe "#average_monthly_open_and_close" do
    it "should correctly calculate the average monthly open and close price for a given ticker" do
      allow(subject).to receive(:raw_stock_data_for_ticker).with("STOCK").and_return(data_for_ticker)

      expect(subject.send(:average_monthly_open_and_close, "STOCK")).to eq(
        [
          {"month"=>"2017-01", "average_open"=>110.0, "average_close"=>160.0},
          {"month"=>"2017-02", "average_open"=>0, "average_close"=>0},
          {"month"=>"2017-03", "average_open"=>0, "average_close"=>0},
          {"month"=>"2017-04", "average_open"=>0, "average_close"=>0},
          {"month"=>"2017-05", "average_open"=>0, "average_close"=>0},
          {"month"=>"2017-06", "average_open"=>0, "average_close"=>0}
        ]
      )
    end
  end

  describe "#max_daily_profit" do
    it "should correctly calculate the maximum daily profit for a given ticker" do
      allow(subject).to receive(:raw_stock_data_for_ticker).with("STOCK").and_return(data_for_ticker)

      expect(subject.send(:max_daily_profit, "STOCK")).to eq({
        "date" => "2017-01-01",
        "max_profit" => 200.0,
        "low" => 0.0,
        "high" => 200.0
      })
    end
  end

  describe "#busy_days" do
    it "should correctly calculate the number of busy days for a given ticker" do
      allow(subject).to receive(:raw_stock_data_for_ticker).with("STOCK").and_return(data_for_ticker)

      expect(subject.send(:busy_days, "STOCK")).to eq({
        'average_volume' => 12641.33,
        'busy_days' => []
      })
    end
  end

  describe "#losing_days" do
    it "should correctly calculate the number of days a ticker's closing price was lower than the opening price" do
      allow(subject).to receive(:raw_stock_data_for_ticker).with("STOCK").and_return(data_for_ticker)

      expect(subject.send(:losing_days, "STOCK")).to eq(0)
    end
  end
end
