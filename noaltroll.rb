#encoding: utf-8
##################
# TP1 - Ing 2
# Grupo 4
##################

require 'sinatra'
require 'haml'
require 'set'

class String
	def dos_o_mas_a_mayusculas
		salida=""
		c_anterior=""
		downcase.each_char do |c|
			if (c!=c_anterior) 
				salida << c
				c_anterior=c
			else
				salida[salida.size-1]=salida[salida.size-1].upcase
			end
		end
		return salida
	end
	def existe_palabra? palabra
		er=""
		palabra.dos_o_mas_a_mayusculas.each_char do |c|
			if c.capitalize == c
				er=er+c
			else
				er=er+"["+c+c.capitalize+"]"
			end
		end
		return Regexp.new(er).match(self)
	end
end

class CategoriaPrefijos

	def initialize raices, prefijos
		@palabras = Set.new 
		raices.each {|raiz| prefijos.each {|prefijo| @palabras.add prefijo+raiz}}
	end
	
	def palabras
		@palabras
	end
end

class CategoriaSufijos

	def initialize raices, sufijos
		@palabras = Set.new 
		raices.each {|raiz| sufijos.each {|sufijo| @palabras.add raiz+sufijo}}
	end
	
	def palabras
		@palabras
	end
end

class EliminarSeparaciones
	def limpiarTexto texto
		return texto.gsub(/[^[[:alnum:]]]/,"")
	end
end

class ReemplazarTexto

	def initialize reemplazos
		@reemplazos = reemplazos
	end
	
	def limpiarTexto texto
		textoLimpio = texto
		@reemplazos.keys.each {|clave| textoLimpio.gsub! clave, @reemplazos[clave]}
		return textoLimpio
	end
end

class EliminarRepeticiones
	def limpiarTexto texto
		return texto.dos_o_mas_a_mayusculas
	end
end

class BuscadorDeEvidencia
	def initialize(categorias)
		@categorias = categorias
	end
	def buscarInsultos comentario
		encontrados = Set.new
		@categorias.each do |c|
			c.palabras.each do |p|
				if comentario.existe_palabra? p
					encontrados << p
				end
			end
		end
		encontrados
	end
end

class FiltradorDeTexto
	def initialize filtros
		@filtros = filtros
	end
	def filtrarTexto texto
		resultados = []
		@filtros.to_a.permutation.each do |perm|
			textoFiltrado = texto
			perm.each {|unFiltro| textoFiltrado = unFiltro.limpiarTexto textoFiltrado}
			resultados << textoFiltrado
		end
		resultados
	end
end

class Evidencia
	def initialize(palabras, comentario)
		@palabras = palabras
		@comentario = comentario
	end
	def palabras
		@palabras
	end
	def comentario
		@comentario
	end
end

class AnalizadorDeEvidencia
	def publicable?
		false
	end
	def dudoso?
		false
	end
end

class AnalizadorBasico < AnalizadorDeEvidencia
	def initialize(evidencia)
		@evidencia = evidencia
	end
	def publicable?
		self.insultos.empty?
	end
	def insultos
		@evidencia.palabras
	end
end

class Moderador
	def initialize buscador, filtrador, analizador
		@buscador = buscador
		@filtrador = filtrador
		@analizador = analizador
	end

	def analizarComentario comentario_p
		comentario=String.new(comentario_p)
		insultosDetectados = Set.new
		@filtrador.filtrarTexto(comentario).each do |unTextoFiltrado|
			insultosDetectados.merge (@buscador.buscarInsultos unTextoFiltrado)
		end
		evidencia = Evidencia.new insultosDetectados, comentario
		@analizador.new evidencia
	end
		
end

# Categorias

raices = ["bolud","pelotud","put","forr"]

literal = CategoriaSufijos.new raices, Set["o", "a", "e"]
flexionado = CategoriaSufijos.new raices, Set["os", "as", "es"]
diminutivo = CategoriaSufijos.new raices, Set["ito", "ita", "itos", "itas", "in", "ines" ]
aumentativo = CategoriaSufijos.new raices, Set["ote", "ota", "azo", "aza", "on", "ona", "isima", "isimo"]
peyorativo = CategoriaSufijos.new raices, Set[ "oncho", "oncha", "onchos", "onchas", "ongo", "ongos", "onga", "ongas" ]

# Filtros

simbolosPorLetras = ReemplazarTexto.new Hash['0'=>'o','1'=>'l','4'=>'a','3'=>'e','5'=>'s','2'=>'dos', '6'=>'g', 
                                             'á'=>'a','é'=>'e','í'=>'i','ó'=>'o','ú'=>'u','7'=>'t']
eliminarSeparaciones = EliminarSeparaciones.new
eliminarRepeticiones = EliminarRepeticiones.new
fonetico = ReemplazarTexto.new Hash['ah'=>'a','eh'=>'e','ih'=>'i','oh'=>'o','uh'=>'u']

# Empieza el codigo de UI

# mantener sesiones mayores a 4k
use Rack::Session::Pool, :expire_after => 2592000


get '/' do
  session[:categorias] = {:literal => literal, :flexionado => flexionado, :diminutivo => diminutivo, :aumentativo => aumentativo, :peyorativo => peyorativo}
  session[:filtros] = {:simbolosPorLetras => simbolosPorLetras, :eliminarSeparaciones => eliminarSeparaciones, :eliminarRepeticiones => eliminarRepeticiones, :fonetico => fonetico}
  haml :form
end

get '/hi' do
  haml :hola
end

post '/procesar_mensaje' do
  msg = params[:mensaje]
  session[:mensaje] = msg

  categorias = Set.new
  session[:categorias].each do |x,y|
    if params[x]
        categorias << y
    end
  end

  if params[:prefijos]
      palabras = Set.new
      categorias.each {|unaCategoria| palabras.merge(unaCategoria.palabras)}

      categorias_prefijo = Set.new
      categorias_prefijo.add ( CategoriaPrefijos.new palabras, Set[ "hiper", "super", "re", "remil" ] )

      categorias.merge(categorias_prefijo)
  end

  buscador = BuscadorDeEvidencia.new categorias

  filtros = Set.new
  session[:filtros].each do |x,y|
    if params[x]
        filtros << y
    end
  end
  filtrador = FiltradorDeTexto.new filtros

  moderador = Moderador.new buscador, filtrador, AnalizadorBasico
  session[:resultado] = moderador.analizarComentario(msg)

  redirect '/hi'
end
