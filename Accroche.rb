##
# Classe représentant l'accroche d'une information, héritant de la classe
# Element.
#
# Une arroche est caractérisée par sa formulation.

require_relative 'Element.rb'
require_relative 'String.rb'

class Accroche < Element
	
	# @accroche		=> Formulation de l'accroche
	
	private_class_method :new
	
	## Création de l'accroche
	def Accroche.creer(accroche, poids)
		new(accroche, poids)
	end
	
	## Pour initialiser une accroche, il faut l'accroche (une chaîne de
	# caractères) et son poids.
	def initialize(accroche, poids)
		super(poids)
		@accroche = accroche
	end
	
	## Donne l'accroche (une chaîne de caractères) juste après l'avoir évaluée.
	def accroche
		return @accroche.evaluer
	end
	
	## Conversion en chaîne de caractères.
	def to_s
		return self.accroche
	end
	
end
