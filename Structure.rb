require_relative 'Element.rb'
require_relative 'String.rb'

##
# Classe représentant la structure d'un post, héritant de la classe Element.
#
# Une structure est caractérisée par sa structure.

class Structure < Element
	
	# @structure	=> Structure du post
	
	##
	# Pour créer une structure, il faut la structure (une chaîne de  caractères)
	# et son poids.
	def Structure.creer(structure, poids)
		new(structure, poids)
	end
	
	## Méthode privée
	def initialize(structure, poids)
		super(poids)
		@structure = structure
	end
	
	##
	# Donne la structure (une chaîne de caractères) juste après l'avoir évaluée.
	def structure
		return @structure.evaluer
	end
	
	## Convertie la structure en chaîne
	def to_s
		return self.structure
	end
	
end
