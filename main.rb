     
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

  difference = amount_total - sell_amount.to_f

  return difference

end

def calculate_ave_cost(trades, sale_index, remainder, last_buy_index)
  sale_amount = trades[sale_index]['amount'].to_f
  # i = last_buy_index
  if remainder == 0
    total_amount = 0
    total_total = 0
  else
    total_amount = remainder
    total_total = (remainder / trades[last_buy_index]['amount'].to_f) * trades[last_buy_index]['total'].to_f
  end

  trades.each_with_index do |trade, index|

    if trade['user_id'] == current_user()['id']


      if trade['trade_type'] == 'BUY'
        total_amount += trade['amount'].to_f
        total_total += trade['total'].to_f
        
      end

      if sale_amount <= total_amount
        last_buy_index = index
        break
      end

    end

  end
  
  
  remainder = total_amount - sale_amount
  average_cost = total_total / total_amount 

  return [average_cost, remainder, last_buy_index]

end

def calculate_realised(trades)

  sale_counter = 0
  remainder = 0
  last_buy_index = 0
  profit_array = []

  trades.each_with_index do |trade,index|
    if trade['user_id'] == current_user()['id']

      if trade['trade_type'] == 'SELL'
        # if sale_counter > 0
        #   check_previous_sales()
        # end
    
        # ave_return equal to array [average cost, remainder, last buy index]
        ave_return = calculate_ave_cost(trades, index, remainder, last_buy_index)

        trade_profit = (trade['price'].to_f - ave_return[0]) * trade['amount'].to_f
        profit_array.push(trade_profit)
        remainder = ave_return[1]
        last_buy_index = ave_return[2]
        sale_counter = sale_counter + 1 
      end

    end
  end
  
  real_profit = profit_array.sum
  return real_profit
end

# def calculate_unrealised(trades)






#   return unreal_profit
# end



get '/' do
  
  result_string = HTTParty.get("https://api.coindesk.com/v1/bpi/currentprice.json")

  result = JSON.parse(result_string)

  price = result['bpi']['USD']['rate_float'].round(2)

  session[:usd_price] = price

  if logged_in?
    trades = run_sql('SELECT * FROM trades ORDER BY trade_date ASC;')
    if logged_in?
      amount_total = getTotal(trades)
    end

    realised_profit = calculate_realised(trades)
  else 

    trades = 0
    realised_profit = 0

  end

  # unrealised_profit = calculate_unrealised(trades)

  erb :index, locals: {
    amount_total: amount_total,
    trades: trades,
    current_price_usd: price,
    disclaimer: result['disclaimer'],
    real_profit: realised_profit.round(2)
  }

end

get '/trades/new' do
  
 erb :new_trade

end

get '/trades/preview' do
  
  total = params[:amount].to_f * params[:price].to_f

  erb :preview, locals: {
    trade_date: params[:trade_date],
    trade_type: params[:trade_type],
    amount: params[:amount],
    price: params[:price],
    total: total
  }

end


post '/trades' do
  if params[:trade_type] == 'SELL'
    difference = check_difference(params[:amount])


    if difference < 0 
      redirect '/submission_error'
    end

  end

  total = params[:amount].to_f * params[:price].to_f

  run_sql("INSERT INTO trades (trade_date, trade_type, amount, price, total, user_id) VALUES ($1, $2, $3, $4, $5, $6);",[params[:trade_date],params[:trade_type],params[:amount],params[:price],total,current_user()['id']])


  redirect '/'

end

get '/trades/:id/edit' do

  trades = run_sql('SELECT * FROM trades where id = $1',[params[:id]])

  erb :edit_trade, locals: { trade: trades[0] }

end

patch '/trades/:id' do

  redirect '/login' unless logged_in?

  total = params[:amount].to_f * params[:price].to_f

  run_sql('UPDATE trades set trade_date = $1, trade_type = $2, amount = $3, price = $4, total = $5 where id = $6;', [params[:trade_date],params[:trade_type], params[:amount], params[:price], total, params[:id]])

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