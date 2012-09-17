require 'noaltroll_clases'

class Aumentativo < Categoria
  def en_mensaje(mensaje)
    terminaciones=%w(on ote azo isima)
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

class Prefijo < Categoria
  def en_mensaje(mensaje)
    prefijos=%w(re hiper super ultra)
    m=""
    prefijos.take_while { |t| (m=/#{t+@palabra.to_s}/.match(mensaje).to_s) == "" }
    r=Respuesta.new(@palabra,mensaje.index(m),m,self.class) if m!=""
    r=Respuesta.no_encontrado(self.class) if m==""
    r
  end
end

