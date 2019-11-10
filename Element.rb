##
# Classe représentant un élément d'une information, qui peut être un personnage,
# une situation, un lieu, une date, une déclaration...
#
# Un élément possède un identifiant dans la base de données et un poids, qui
# influence sur son choix aléatoire.

class Element
	
	## Identifiant d'un élément
	attr :id, false
	## Poids d'un élément, accessible en lecture.
	attr :poids, false
	
	# La classe est une classe abstraite.
	private_class_method :new
	
	## Pour initialiser un élément il faut son identifiant et son poids.
	def initialize(id, poids)
		@id = id
		@poids = poids
	end
	
	## Convertie l'élément en chaîne de caractère
	def to_s
		raise "L'élément est vide"
	end
	
	## Retourne la valeur demandée
	def retourner(attribut, parametres)
		return self.to_s
	end
	
end
