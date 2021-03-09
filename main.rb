     
require 'sinatra'
require 'pg'
require 'bcrypt'
require 'httparty'

require_relative 'db/lib.rb'

if development?
  require 'sinatra/reloader'
  require 'pry'
end 

get '/' do
  
  trades = run_sql('SELECT * FROM trades')

  amount_total = 0

  trades.each do |trade|
    if trade['trade_type'] == 'BUY'
      amount_total = amount_total + trade['amount'].to_f
    else
      amount_total = amount_total - trade['amount'].to_f
    end
  end
  
  "#{amount_total}"
  
  
  erb :index, locals: {
    amount_total: amount_total,
    trade_date: trade['trade_date'],
    trade_type: trade['trade_type'],
    amount: trade['amount'],
    price: trade['price'],
    total: trade['total']
  }
end





