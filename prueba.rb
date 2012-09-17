$:.insert 0,"."  # agrega el dir actual para busqueda del require

require 'noaltroll_categorias'

i1=Palabra.new(:palabra=>'pelotudo',:raiz=>'pelotud')
i2=Palabra.new(:palabra=>'puto',:raiz=>'put')

insultos=Array.new 
insultos << i1 << i2

insultos.each do |insulto|
  Categoria.subclasses.each do |buscar| 
    r=((buscar .el insulto) .en_mensaje "la puta que te pario, pelotudo" )
    puts r.palabra.to_s ,r.posicion.to_s ,r.string_hallado ,r.categoria.to_s if r.encontrado
    puts
  end
end
