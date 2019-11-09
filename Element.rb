##
# Classe représentant un élément d'une information, qui peut être un personnage,
# une situation, un lieu, une date, une déclaration...
#
# Un élément possède un poids, qui influence sur son choix aléatoire.

class Element
	
	## Poids d'un élément, accessible en lecture.
	attr :poids, false
	
	# La classe est une classe abstraite.
	private_class_method :new
	
	## Pour initialiser un élément il faut son poids.
	def initialize(poids)
		@poids = poids
	end
	
end
