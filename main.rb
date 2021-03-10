     
require 'sinatra'
require 'pg'
require 'bcrypt'
require 'httparty'

require_relative 'db/lib.rb'

enable :sessions

def logged_in?()
  if session[:user_id]
    return true
  else
    return false
  end
end

if development?
  require 'sinatra/reloader'
  require 'pry'
end 

def get_total(trades)
  amount_total = 0

  trades.each do |trade|
    
      if trade['user_id'] == current_user()['id']
        if trade['trade_type'] == 'BUY'
          amount_total = amount_total + trade['amount'].to_f
        else
          amount_total = amount_total - trade['amount'].to_f
        end
      end

  end

  return amount_total
end

def current_user

  results = run_sql('SELECT * FROM users where id = $1;',[session[:user_id]])

  return results.first

end

def check_difference(sell_amount)
  db = PG.connect(ENV['DATABASE_URL'] || {dbname: 'bitfolio'})
  trades = db.exec_params('select * from trades where user_id = $1', [current_user()['id']])

  if trades.count < 1
    return -1
  end

  amount_total = get_total(trades)

  difference = amount_total - sell_amount

  return difference

end


get '/' do
  
  result_string = HTTParty.get("https://api.coindesk.com/v1/bpi/currentprice.json")

  result = JSON.parse(result_string)

  price = result['bpi']['USD']['rate_float'].round(2)

  trades = run_sql('SELECT * FROM trades ORDER BY trade_date ASC;')
  if logged_in?
    amount_total = getTotal(trades)
  end

  erb :index, locals: {
    amount_total: amount_total,
    trades: trades,
    current_price_usd: price,
    disclaimer: result['disclaimer']
  }

end

get '/trades/new' do
  
 erb :new_trade

end

post '/trades' do
  if params[:trade_type] == 'SELL'
    difference = check_difference(params[:amount_total])
    if difference < 0 
      redirect '/submission_error'
    end

  end

  run_sql("INSERT INTO trades (trade_date, trade_type, amount, price, total, user_id) VALUES ($1, $2, $3, $4, $5, $6);",[params[:trade_date],params[:trade_type],params[:amount],params[:price],params[:total],current_user()['id']])


  redirect '/'

end

get '/trades/:id/edit' do

  trades = run_sql('SELECT * FROM trades where id = $1',[params[:id]])

  erb :edit_trade, locals: { trade: trades[0] }

end

patch '/trades/:id' do

  redirect '/login' unless logged_in?

  run_sql('UPDATE trades set trade_date = $1, trade_type = $2, amount = $3, price = $4, total = $5 where id = $6;', [params[:trade_date],params[:trade_type], params[:amount], params[:price], params[:total], params[:id]])

  redirect '/'

end

delete '/trades/:id' do

  redirect '/login' unless logged_in?

  run_sql('DELETE FROM trades WHERE id = $1;',[ params[:id] ])

  redirect '/'

end

get '/login' do
  
  erb :login

end

post '/sessions' do

  results = run_sql("SELECT * FROM users WHERE username = $1;",[params[:username]])

  if results.count == 1 && BCrypt::Password.new(results[0]['password_digest']).==(params[:password])

    session[:user_id] = results[0]['id']
    
    redirect '/'

  else

    erb :login

  end

end

delete '/sessions' do

  session[:user_id] = nil
  
  redirect '/login'

end

get '/signup' do
  
  erb :signup

end

post '/users' do
  
  username = params['username']
  password = params['password']

  password_digest = BCrypt::Password.create(password)

  run_sql('INSERT INTO users (username, password_digest) VALUES ($1, $2);',[username, password_digest])

  redirect '/login'
end



get '/submission_error' do
  
  erb :submission_error
end