class Categoria

  #####################################
  # Metodos de clase
  #####################################

  @@subclasses=Array.new
  # Cada vez que se crea una subclase la agrega al array
  def self.inherited(subclass)
    @@subclasses << subclass
  end

  # Cosmetica
  def self.el_insulto(*args)
    self.new(*args)
  end

  # Devuelve el array con las subclases
  def self.subclasses
    @@subclasses
  end

  #####################################
  # Metodos de Instancia
  #####################################

  # Implementado aca porque es comun a todas las subclases
  def initialize(palabra)
    @palabra=palabra
  end

end

class Palabra
  def initialize(hash)
    @palabra=hash[:palabra]
    @raiz=hash[:raiz]
  end
  def raiz
    @raiz
  end
  def to_s
    @palabra
  end
end

class Respuesta
  def self.no_encontrado(categoria)
    self.new(Palabra.new(:palabra=>"",:raiz=>""),0,"",categoria)
  end
  def initialize(palabra,posicion,string_hallado,categoria)
    @encontrado=(palabra.to_s!="")
    @palabra=palabra
    @posicion=posicion
    @string_hallado=string_hallado
    @categoria=categoria
  end
  def palabra
    @palabra
  end
  def posicion
    @posicion
  end
  def categoria
    @categoria
  end
  def string_hallado
    @string_hallado
  end
  def encontrado
    @encontrado
  end
end
