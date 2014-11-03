require 'sinatra'
require './helpers'

get '/' do
  erb :index
end

get '/disk' do
  erb :disk
end

get '/memory' do
  erb :memory
end
