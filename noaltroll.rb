# TP1

require 'sinatra'
require 'haml'

enable :sessions

get '/' do
  haml :form
end

get '/hi' do
  @msg=session[:msg]
  haml :hola
end

post '/procesar_mensaje' do
  session[:msg]=params[:mensaje]
  redirect '/hi'
end
