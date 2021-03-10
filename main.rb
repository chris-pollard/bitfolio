     
require 'sinatra'
require 'pg'
require 'bcrypt'
require 'httparty'

require_relative 'db/lib.rb'

if development?
  require 'sinatra/reloader'
  require 'pry'
end 

def getTotal(trades)
  amount_total = 0

  trades.each do |trade|
    if trade['trade_type'] == 'BUY'
      amount_total = amount_total + trade['amount'].to_f
    else
      amount_total = amount_total - trade['amount'].to_f
    end
  end

  return amount_total
end

get '/' do
  
  trades = run_sql('SELECT * FROM trades')

  amount_total = getTotal(trades)
  
  erb :index, locals: {
    amount_total: amount_total,
    trades: trades
  }

end

get '/trades/new' do
  
 erb :new_trade

end

post '/trades' do

  run_sql("INSERT INTO trades (trade_date, trade_type, amount, price, total) VALUES ($1, $2, $3, $4, $5)",[params[:trade_date],params[:trade_type],params[:amount],params[:price],params[:total]])

  redirect '/'

end

get '/trades/:id/edit' do

  trades = run_sql('SELECT * FROM trades where id = $1',[params[:id]])

  erb :edit_trade, locals: { trade: trades[0] }

end

patch '/trades/:id' do

  run_sql('UPDATE trades set trade_date = $1, trade_type = $2, amount = $3, price = $4, total = $5 where id = $6;', [params[:trade_date],params[:trade_type], params[:amount], params[:price], params[:total], params[:id]])

  redirect '/'

end

delete '/trades/:id' do

  run_sql('DELETE FROM trades WHERE id = $1;',[ params[:id] ])

  redirect '/'

end