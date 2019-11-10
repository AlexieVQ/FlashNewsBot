require_relative 'Element.rb'
require_relative 'String.rb'

##
# Classe représentant le nom d'un personnage.
#
# Un nom est caractérisé par sa chaîne de caractère et son poids. Il peut
# retourner sa chaîne de caractères après l'avoir évaluée.

class NomPers < Element
	
	# @nom			=> Nom du personnage
	
	##
	# Pour créer un nom, il faut son identifiant, sa chaîne de caractères et son
	# poids.
	def NomPers.creer(id, nom, poids)
		new(id, nom, poids)
	end
	
	## Méthode privée
	def initialize(id, nom, poids)
		super(id, poids)
		@nom = nom
	end
	
	## Donne le nom de la personne, avec l'article donné
	def nom(article = nil)
		return @nom.evaluer.modif_article(article)
	end
	
	## Conversion en chaîne de caractères
	def to_s
		return self.nom
	end
	
	## Retourne le nom avec les paramètres donnés (article)
	def retourner(attribut, parametres)
		return self.nom(parametres[0])
	end
	
end
