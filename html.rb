require 'rubygems'
require 'sinatra'
require 'nokogiri'
require 'lib/evaluator'

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
  @text = Evaluator.new(params[:text]).e
  erb :template
end