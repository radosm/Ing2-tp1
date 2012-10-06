##################
# TP1 - Ing 2
# Grupo 4
##################

require 'noaltroll_categorias'

###############################
# Arma colección de insultos
###############################
$insultos=Array.new 
$insultos << Palabra.new(:palabra=>'pelotudo',:raiz=>'pelotud')
$insultos << Palabra.new(:palabra=>'puto',:raiz=>'put')
$insultos << Palabra.new(:palabra=>'boludo',:raiz=>'bolud')

#############################################
# Funcion para llamar desde aplicacion web
#############################################
def analizar_mensaje(msg)
  respuesta=Array.new
  $insultos.each do |i|
    Categoria.subclasses.each do |buscar| 
      r=(buscar .el_insulto i) .en_mensaje msg
      respuesta << r if r.encontrado
    end
  end
  respuesta
end
