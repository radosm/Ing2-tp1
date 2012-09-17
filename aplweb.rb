##################
# TP1 - Ing 2
# Grupo 4
##################

$:.insert 0,"."  # agrega el dir actual para busqueda del require

require 'sinatra'
require 'haml'
require 'noaltroll'

enable :sessions


get '/' do
  haml :form
end

get '/hi' do
  @msg=session[:mensaje]
  @resultado=session[:resultado]
  haml :hola
end

post '/procesar_mensaje' do
  msg=params[:mensaje]
  session[:mensaje]=msg
  session[:resultado]=""
  analizar_mensaje(msg).each do |r|
    session[:resultado]=session[:resultado]+"   *****   Literal: "+r.palabra.to_s+" Posicion: "+r.posicion.to_s+" string_hallado: "+r.string_hallado+" Categoria: "+r.categoria.to_s if r.encontrado
  end
  redirect '/hi'
end
