require 'sinatra'
require 'haml'

enable :sessions

get '/' do
  redirect to ('/form');
end

get '/hi' do
  @msg=session[:msg]
  haml :hola
end

get '/form' do
  haml :f
end

post '/procesar_mensaje' do
  session[:msg]=params[:mensaje]
  redirect '/hi'
end
