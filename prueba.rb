$:.insert 0,"."  # agrega el dir actual para busqueda del require

require 'noaltroll_categorias'

i1=Palabra.new(:palabra=>'pelotudo',:raiz=>'pelotud')
i2=Palabra.new(:palabra=>'puto',:raiz=>'put')

insultos=Array.new 
insultos << i1 << i2

insultos.each do |i|
  Categoria.subclasses.each do |buscar| 
    r=(buscar .el_insulto i) .en_mensaje "la reputisima madre que te pario, superpelotudo"
    puts r.palabra.to_s ,r.posicion.to_s ,r.string_hallado ,r.categoria.to_s if r.encontrado
    puts
  end
end
