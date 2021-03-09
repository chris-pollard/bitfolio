     
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
  erb :index
end





