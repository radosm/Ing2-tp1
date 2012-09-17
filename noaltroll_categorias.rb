require 'noaltroll_clases'

class Aumentativo < Categoria
  def en_mensaje(mensaje)
    terminaciones=%w(on ote azo)
    m=""
    terminaciones.take_while { |t| (m=/#{@palabra.raiz+t}/.match(mensaje).to_s) == "" }
    r=Respuesta.new(@palabra,mensaje.index(m),m,self.class) if m!=""
    r=Respuesta.no_encontrado(self.class) if m==""
    r
  end
end

class Flexionado < Categoria
  def en_mensaje(mensaje)
    terminaciones=%w(o a as os)
    m=""
    terminaciones.take_while { |t| (m=/#{@palabra.raiz+t}/.match(mensaje).to_s) == "" }
    r=Respuesta.new(@palabra,mensaje.index(m),m,self.class) if m!=""
    r=Respuesta.no_encontrado(self.class) if m==""
    r
  end
end

