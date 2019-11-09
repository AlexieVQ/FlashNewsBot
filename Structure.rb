##
# Classe représentant la structure d'un post, héritant de la classe Element.
#
# Une structure est caractérisée par sa structure.

require_relative 'Element.rb'

class Structure < Element
	
	# @structure	=> Structure du post
	
	private_class_method :new
	
	## Création de la structure
	def Structure.creer(structure, poids)
		new(structure, poids)
	end
	
	## Pour initialiser une structure, il faut la structure (une chaîne de
	# caractères) et son poids.
	def initialize(structure, poids)
		super(poids)
		@structure = structure
	end
	
	## Donne la structure (une chaîne de caractères) juste l'avoir évaluée.
	def structure
		return @structure.evaluer
	end
	
end
