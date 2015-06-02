require 'net/http'
require 'uri'
require 'json'
require 'yaml'
require_relative 'helpers.rb'

class Spending
  attr_accessor :session, :balance_json, :transactions_json, :goals_json, :transactions_yesterday
  def initialize
    @sign_in = URI("#{ENV['S_URL']}/signin")
    @session = sign_in
    
    @balance_json = get("#{ENV['S_URL']}/account/balances",@session)
    @transactions_json = get("#{ENV['S_URL']}/transactions/data",@session)
    @goals_json = get("#{ENV['S_URL']}/goals/data",@session)

    @transactions_yesterday = days_ago(1)
  end    
end