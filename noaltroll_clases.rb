class Palabra
  def initialize(h)
    @palabra=h[:palabra]
    @raiz=h[:raiz]
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

class Categoria

  @@subclasses=Array.new

  # Cosmetica
  def self.el(*args)
    self.new(*args)
  end

  # Devuelve las subclases
  def self.subclasses
    @@subclasses
  end

  def initialize(palabra)
    @palabra=palabra
  end

  # Cada vez que se crea una subclase la agrega al array
  def self.inherited(subclass)
    @@subclasses << subclass
  end

end

