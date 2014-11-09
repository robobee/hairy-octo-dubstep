require 'rubygems'
require 'sinatra'
require 'mongo'
require './helpers'

include Mongo

configure do
  conn = MongoClient.new("localhost", 27017)
  set :mongo_connection, conn
  set :mongo_db, conn.db('test')
end

get '/' do
  erb :index
end

get '/disk/?' do
  erb :disk
end

get '/memory/?' do
  erb :memory
end

get '/memory/history/?' do
  erb :memory_history
end

get '/disk/history/?' do
  erb :disk_history
end

post '/save_memory_data' do
  save_memory_data
  redirect to('/memory')
end

post '/save_disk_data' do
  save_disk_data
  redirect to('/disk')
end
