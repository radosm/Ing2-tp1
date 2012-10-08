require 'set'

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

class CategoriaReemplazarTexto

	def initialize reemplazos
		@reemplazos = reemplazos
	end
	
	def limpiarTexto texto
		textoLimpio = texto
		@reemplazos.keys.each {|clave| textoLimpio = textoLimpio.tr clave, @reemplazos[clave]}
		return textoLimpio
	end
end

class CategoriaEliminarRepeticiones
	
	def limpiarTexto texto
		textoLimpio = ""
		i = 0
		texto.gsub!(/l{2,}/,"L")
		texto.gsub!(/r{2,}/,"R")
		while i < texto.size
			textoLimpio << texto[i]
			c = texto[i]
			while texto[i] == c
				i += 1
			end
		end
		return textoLimpio
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
				if comentario.include? p.gsub(/l{2,}/,"L").gsub(/r{2,}/,"R")
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

class Analizador
	def publicable?
		false
	end
	def dudoso?
		false
	end
end

class AnalizadorBasico < Analizador
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
		@filtrador.filtrarTexto(comentario.downcase).each do |unTextoFiltrado|
			insultosDetectados.merge (@buscador.buscarInsultos unTextoFiltrado)
		end
		evidencia = Evidencia.new insultosDetectados, comentario
		@analizador.new evidencia
	end
		
end

# Categorias

raices = ["bolud","pelotud","put","forr","pollerud"]

literal = CategoriaSufijos.new raices, Set["o", "a"]
flexionado = CategoriaSufijos.new raices, Set["os", "as"]
diminutivo = CategoriaSufijos.new raices, Set["ito", "ita"]
aumentativo = CategoriaSufijos.new raices, Set["ote", "ota"]

simbolosPorLetras = CategoriaReemplazarTexto.new Hash['0'=>'o','1'=>'l']
letrasSeparadas = CategoriaReemplazarTexto.new Hash[' '=>'', '/'=>'', '.'=>'', ','=>'']


# Analizador

buscador = BuscadorDeEvidencia.new Set[literal, flexionado, diminutivo, aumentativo]
filtrador = FiltradorDeTexto.new Set[simbolosPorLetras, letrasSeparadas, CategoriaEliminarRepeticiones.new]
moderador = Moderador.new buscador, filtrador, AnalizadorBasico

# Pruebas

comentario = "hola, como andas?"
print comentario+":  "+ moderador.analizarComentario(comentario).publicable?.to_s+"\n"
comentario = "hola boludo, como andas?"
print comentario+":  "+ moderador.analizarComentario(comentario).publicable?.to_s+"\n"
comentario = "hola b0ludo, como andas?"
print comentario+":  "+ moderador.analizarComentario(comentario).publicable?.to_s+"\n"
comentario = "hola b 0 ludo, como andas?"
print comentario+":  "+ moderador.analizarComentario(comentario).publicable?.to_s+"\n"
comentario = "hola puutooo, como andas?"
print comentario+":  "+ moderador.analizarComentario(comentario).publicable?.to_s+"\n"
comentario = "hola put0 o, como andas?"
print comentario+":  "+ moderador.analizarComentario(comentario).publicable?.to_s+"\n"
comentario = "hola forro, como andas?"
print comentario+":  "+ moderador.analizarComentario(comentario).publicable?.to_s+"\n"
comentario = "hola pollerudo, como andas?"
print comentario+":  "+ moderador.analizarComentario(comentario).publicable?.to_s+"\n"
