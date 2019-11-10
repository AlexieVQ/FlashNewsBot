require_relative 'Element.rb'
require_relative 'String.rb'

##
# Classe représentant le lieu d'une information.
#
# Un lieu est caractérisé par sa chaîne de caractère.

class Lieu < Element
	
	# @lieu		=> Chaîne de caractères
	
	##
	# Pour créer un lieu, il nous faut son identifiant, sa chaîne de caractères
	# et son poids.
	def Lieu.creer(id, lieu, poids)
		new(id, lieu, poids)
	end
	
	## Méthode privée
	def initialize(id, lieu, poids)
		super(id, poids)
		@lieu = lieu
	end
	
	## Donne le lieu stocké, après l'avoir évalué.
	def lieu
		return @lieu.evaluer
	end
	
	## Retourne le lieu stocké, après l'avoir évalué.
	def to_s
		return self.lieu
	end
	
end
