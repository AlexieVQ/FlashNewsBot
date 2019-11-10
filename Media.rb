require_relative 'Element.rb'
require_relative 'String.rb'

##
# Classe représentant un média.
#
# Un média est caractérisé par son nom.

class Media < Element
	
	# @nom		=> Nom du média
	
	##
	# Pour créer un média, il faut son identifiant, son nom et son poids.
	def Media.creer(id, nom, poids)
		new(id, nom, poids)
	end
	
	## Méthode privée
	def initialize(id, nom, poids)
		super(id, poids)
		@nom = nom
	end
	
	## Retourne le nom du média, après l'avoir évalué, avec l'article donné
	def nom(article)
		return @nom.evaluer.modif_article(article)
	end
	
	## Retourne le nom du média, après l'avoir évalué
	def to_s
		return self.nom
	end
	
	##
	# Retourne l'attribut avec les paramètres demandés.  
	# Attributs possibles :
	# - "nom"
	# Paramètres :
	# - Article pour le nom
	def retourner(attribut, parametres)
		case attribut
		when "nom"
			return self.nom(parametres[0])
		else
			return self.to_s
		end
	end
	
end
