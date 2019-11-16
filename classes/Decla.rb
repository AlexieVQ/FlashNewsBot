require_relative 'Element.rb'
require_relative 'String.rb'

##
# Classe représentant la déclaration d'un personnage.
#
# Une déclaration est caractérisée par sa chaîne de caractères.

class Decla < Element
	
	# @decla		=> Chaîne de caractères
	
	##
	# Pour créer une déclaration, il faut son identifiant, sa chaîne de
	# caractères et son poids.
	def Decla.creer(id, decla, poids)
		new(id, decla, poids)
	end
	
	## Méthode privée
	def initialize(id, decla, poids)
		super(id, poids)
		@decla = decla
	end
	
	## Retourne la déclaration (chaîne de caractères) après l'avoir évaluée.
	def decla
		return @decla.evaluer
	end
	
	## Retourne la déclaration (chaîne de caractères) après l'avoir évaluée.
	def to_s
		return self.decla
	end
	
end
