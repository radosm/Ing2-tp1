##################
# TP1 - Ing 2
# Grupo 4
##################

$:.insert 0,"."  # agrega el dir actual para busqueda del require

require 'noaltroll_categorias'

###############################
# Arma colección de insultos
###############################
i1=Palabra.new(:palabra=>'pelotudo',:raiz=>'pelotud')
i2=Palabra.new(:palabra=>'puto',:raiz=>'put')
$insultos=Array.new 
$insultos << i1 << i2

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
