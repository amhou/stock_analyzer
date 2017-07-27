#!/usr/bin/env ruby

require 'optparse'
require_relative '../stock_analyzer.rb'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: stock_analysis.rb [options]"

  opts.on('-a', '--analysis',         'Analysis (Default)') { |v| options[:analysis] = v }
  opts.on('-m', '--max-daily-profit', 'Max Daily Profit')   { |v| options[:max_daily_profit] = v }
  opts.on('-b', '--busy-day',         'Busy Day')           { |v| options[:busy_day] = v }
  opts.on('-l', '--biggest-loser',    'Biggest Loser')      { |v| options[:biggest_loser] = v }
  opts.on('-h', '--help',             'Print this help')    { |v| puts opts; exit }
end.parse!

sa = StockAnalyzer.new

if options.empty? || options[:analysis]
  puts sa.ticker_analysis_average_open_and_close.to_json
elsif options[:max_daily_profit]
  puts sa.ticker_analysis_max_daily_profit.to_json
elsif options[:busy_day]
  puts sa.ticker_analysis_busy_days.to_json
elsif options[:biggest_loser]
  puts sa.ticker_analysis_biggest_loser.to_json
end
