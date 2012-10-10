#encoding: utf-8

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

categorias=Set.new

literal = CategoriaSufijos.new raices, Set["o", "a", "e"]
flexionado = CategoriaSufijos.new raices, Set["os", "as", "es"]
diminutivo = CategoriaSufijos.new raices, Set["ito", "ita", "itos", "itas", "in", "ines" ]
aumentativo = CategoriaSufijos.new raices, Set["ote", "ota", "azo", "aza", "on", "ona", "isima", "isimo"]
peyorativo = CategoriaSufijos.new raices, Set[ "oncho", "oncha", "onchos", "onchas", "ongo", "ongos", "onga", "ongas" ]

categorias_sufijo=Set[ literal, flexionado, diminutivo, aumentativo, peyorativo ]

palabras=Set.new
categorias_sufijo.each { |categoria| palabras.merge(categoria.palabras) }

categorias_prefijo=Set.new
categorias_prefijo.add ( CategoriaPrefijos.new palabras, Set[ "hiper", "super", "re", "remil" ] )

# Crea Moderador

buscador = BuscadorDeEvidencia.new categorias_sufijo.merge(categorias_prefijo)

simbolosPorLetras = ReemplazarTexto.new Hash['0'=>'o','1'=>'l','4'=>'a','3'=>'e','5'=>'s','2'=>'dos', '6'=>'g', 
                                             'á'=>'a','é'=>'e','í'=>'i','ó'=>'o','ú'=>'u','7'=>'t']
fonetico = ReemplazarTexto.new Hash['ah'=>'a','eh'=>'e','ih'=>'i','oh'=>'o','uh'=>'u']
filtrador = FiltradorDeTexto.new Set[simbolosPorLetras, EliminarSeparaciones.new, EliminarRepeticiones.new ,fonetico]
moderador = Moderador.new buscador, filtrador, AnalizadorBasico

# Pruebas nuestras

##[ 
  ##"hola, como andas?", 
  ##"hola boludo, como andas? h i j o d e p/u u u t a",
  ##"hola b0ludo, como andas?",
  ##"hola b 0 ludo, como andas?",
  ##"hola puutooo, como andas?",
  ##"hola pu t 0 o, como andas?",
  ##"hola FORRO, como andas?",
  ##"hola mequ3e3hhhhtrrrefe, como andas?",
  ##"hola pollehhehhrudooooo, como andas?",
  ##"hola foro, como andas? sos un put42o !"
##].each do |comentario|
	##resultado=moderador.analizarComentario(comentario)
	##puts comentario+": "+ resultado.publicable?.to_s+"  -  Insultos: "+(resultado.insultos.to_a).to_s
##end 

# Pruebas de la catedra

[
	"¿Por qué el pollo cruzó el camino?",
	"El pollo este es un pelotudo.",
	"El muy hijo de puta cruzó el camino cuando nadie lo miraba.",
	"Los niños y las niñas son los únicos y las únicas privilegiados y privelegiadas.",
	"Pelotudos y boludas son iguales ante la ley.",
	"Los muy hijos de puta se fueron sin avisarme.",
	"Te mando un besito grande.",
	"¿Quién va a ser, si no el pelotudito de siempre?",
	"¡Tremendo boludín viniste a salir!",
	"De golpe y porrazo me moría de hambre.",
	"Forrazo como no hay dos.",
	"La putísima madre que lo parió.",
	"Libracos no, alpargatuchas sí.",
	"A pelotudoncho no te gana nadie.",
	"El rey de los boludongos.",
	"Hipermercado supercalifragilisticoexpialidoso.",
	"¡Hijo de la remilputa!",
	"Superboludo al rescate.",
	"E-s-p-e-c-t-a-c-u-l-a-r",
	"Se la dió de p.e.l.o.t.u.d.o.",
	"Le pasó x h i j o d e p u t a.",
	"Parece verdadero pelo tu disfraz de gorila.",
	"No te diste cuenta por pelo-tudo.",
	"No te diste cuenta por bo lu do.",
	"Diputados tratan prohibición de llamar ciencia a la computación.",
	"¿Qué mirás, pelotudo.com?",
	"Sólo un hijodeputa puede querer algo así.",
	"L33t a1N7 p-r8 NOR 1am3.",
	"Hay que explicárselo al p3l07udo de siempre.",
	"A los b01u2 hay decírselos dos veces.",
	"Amerika perdida.",
	"¿Es voludo o se hace?",
	"El ijoeputa me dejó de garpe.",
	"El campana: es taaan-tonn-tiiiíín...",
	"Andaaaaáááá, boludoooo.",
	"Rajá, boluuuuudo."
].each do |comentario|
	resultado=moderador.analizarComentario(comentario)
	puts comentario+": "+ resultado.publicable?.to_s+"  -  Insultos: "+(resultado.insultos.to_a).to_s
end
