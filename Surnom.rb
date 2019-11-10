require_relative 'Element.rb'
require_relative 'String.rb'

##
# Classe représentant le surnom d'un personnage.
#
# Un surnom est caractérisé par sa chaîne de caractère et son poids. Il peut
# retourner sa chaîne de caractères après l'avoir évaluée.

class Surnom < Element
	
	# @surnom		=> Surnom du personnage
	
	##
	# Pour créer un surnom, il faut son identifiant, sa chaîne de caractères et
	# son poids.
	def Surnom.creer(id, surnom, poids)
		new(id, surnom, poids)
	end
	
	## Méthode privée
	def initialize(id, surnom, poids)
		super(id, poids)
		@surnom = surnom
	end
	
	## Donne le surnom de la personne, avec l'article donné
	def surnom(article)
		return @surnom.evaluer.modif_article(article)
	end
	
	## Conversion en chaîne de caractères
	def to_s
		return self.surnom
	end
	
	## Retourne le surnom avec les paramètres donnés (article)
	def retourner(attribut, parametres)
		return self.surnom(parametres[0])
	end
	
end
