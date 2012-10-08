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
		@raices = raices
		@prefijos = prefijos
	end
	
	def palabras
		palabras = Set.new 
		@raices.each {|raiz| @prefijos.each {|prefijo| palabras.add prefijo+raiz}}
		return palabras
	end
end

class CategoriaSufijos

	def initialize raices, sufijos
		@raices = raices
		@sufijos = sufijos
	end
	
	def palabras
		palabras = Set.new 
		@raices.each {|raiz| @sufijos.each {|sufijo| palabras.add raiz+sufijo}}
		return palabras
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
		@reemplazos.keys.each {|clave| textoLimpio = textoLimpio.tr clave, @reemplazos[clave]}
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

	def analizarComentario comentario
		insultosDetectados = Set.new
		@filtrador.filtrarTexto(comentario).each do |unTextoFiltrado|
			insultosDetectados.merge (@buscador.buscarInsultos unTextoFiltrado)
		end
		evidencia = Evidencia.new insultosDetectados, comentario
		@analizador.new evidencia
	end
		
end

# Categorias

raices = ["bolud","pelotud","put","forr","pollerud","mequetref"]

literal = CategoriaSufijos.new raices, Set["o", "a", "e"]
flexionado = CategoriaSufijos.new raices, Set["os", "as"]
diminutivo = CategoriaSufijos.new raices, Set["ito", "ita"]
aumentativo = CategoriaSufijos.new raices, Set["ote", "ota", "azo", "aza", "on", "ona"]

simbolosPorLetras = ReemplazarTexto.new Hash['0'=>'o','1'=>'l','4'=>'a','3'=>'e','5'=>'s','2'=>'z', '6'=>'g', '9'=>'q']

# Analizador

buscador = BuscadorDeEvidencia.new Set[literal, flexionado, diminutivo, aumentativo]
filtrador = FiltradorDeTexto.new Set[simbolosPorLetras, EliminarSeparaciones.new, EliminarRepeticiones.new]
moderador = Moderador.new buscador, filtrador, AnalizadorBasico

# Pruebas

[ 
  "hola, como andas?", 
  "hola boludo, como andas? h i j o d e p/u u u t a",
  "hola b0ludo, como andas?",
  "hola b 0 ludo, como andas?",
  "hola puutooo, como andas?",
  "hola put0 o, como andas?",
  "hola FORRO, como andas?",
  "hola mequ33trrrefe, como andas?",
  "hola pollerudooooo, como andas?",
  "hola foro, como andas? sos un put42o !"
].each do |comentario|
	resultado=moderador.analizarComentario(comentario)
	print comentario+": "+ resultado.publicable?.to_s+" Insultos: "+(resultado.insultos.to_a).to_s+"\n"
end
