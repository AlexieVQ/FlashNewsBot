require_relative 'Element.rb'
require_relative 'String.rb'

##
# Classe représentant le nom d'un personnage.
#
# Un nom est caractérisé par sa chaîne de caractère et son poids. Il peut
# retourner sa chaîne de caractères après l'avoir évaluée.

class NomPers < Element
	
	# @nom			=> Nom du personnage
	
	## Identifiant du personnage concernée
	attr :id_pers, false
	
	##
	# Crée un nom à partir d'une ligne d'un fichier CSV.
	def NomPers.importer(ligne)
		new(ligne['id'].to_i, ligne['nom'], ligne['poids'].to_i,
		    ligne['id_pers'].to_i)
	end
	
	## Méthode privée
	def initialize(id, nom, poids, id_pers)
		super(id, poids)
		@nom = nom
		@id_pers = id_pers
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
	def retourner(attribut = nil, parametres = nil)
		return self.nom(parametres[0])
	end
	
end
