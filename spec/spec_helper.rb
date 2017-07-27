require 'rspec'
require 'rspec/mocks'
require 'pry'

require_relative '../stock_analyzer.rb'

RSpec.configure do |config|
  config.order = 'random'
  config.color = true
end
