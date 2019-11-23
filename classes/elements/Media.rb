require_relative 'Element.rb'
require_relative 'String.rb'

##
# Classe représentant un média.
#
# Un média est caractérisé par son nom.

class Media < Element
	
	# @nom		=> Nom du média
	
	## Nom du fichier CSV correspondant
	@@nom_fichier = "medias.csv"
	
	##
	# Crée un média à partir d'une ligne d'un fichier CSV.
	def Media.importer(ligne)
		new(ligne['id'].to_i, ligne['nom'], ligne['poids'].to_i)
	end
	
	## Méthode privée
	def initialize(id, nom, poids)
		super(id, poids)
		@nom = nom
	end
	
	## Retourne le nom du média, après l'avoir évalué, avec l'article donné
	def nom(article = nil)
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
	def retourner(attribut = nil, parametres = nil)
		case attribut
		when "nom" then
			return self.nom(parametres[0])
		else
			return ""
		end
	end
	
end
