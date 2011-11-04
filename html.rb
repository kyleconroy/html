require 'rubygems'
require 'sinatra'
require 'nokogiri'

set :port, 4865 # HTML

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  @text = nil
  erb :template
end

post '/' do
  puts params.inspect
  @text = params[:text]
  debugger
  result = Nokogiri.parse(@text)
  
  erb :blank
end