require_relative 'Element.rb'
require_relative 'String.rb'

##
# Classe représentant les circonstances d'une information.
#
# Une circonstance est caractérisée par sa chaîne de caractères.

class Circo < Element
	
	# @circo		=> Chaîne de caractères
	
	##
	# Pour créer une circonstance, il faut son identifiant, sa chaîne de
	# caractères et son poids.
	def Circo.creer(id, circo, poids)
		new(id, circo, poids)
	end
	
	## Méthode privée
	def initialize(id, circo, poids)
		super(id, poids)
		@circo = circo
	end
	
	## Retourne la circonstance (chaîne de caractères) après l'avoir évaluée.
	def circo
		return @circo.evaluer
	end
	
	## Retourne la circonstance (chaîne de caractères) après l'avoir évaluée.
	def to_s
		return self.circo
	end
	
end
