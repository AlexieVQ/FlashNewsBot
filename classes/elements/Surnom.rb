require_relative 'Element.rb'
require_relative '../String.rb'

##
# Classe représentant le surnom d'un personnage.
#
# Un surnom est caractérisé par sa chaîne de caractère et son poids. Il peut
# retourner sa chaîne de caractères après l'avoir évaluée.

class Surnom < Element
	
	# @surnom		=> Surnom du personnage
	
	## Nom du fichier CSV correspondant
	@@nom_fichier = "surnoms.csv"
	
	## Identifiant du personnage concerné
	attr :id_pers, false
	
	##
	# Crée un surnom à partir d'une ligne d'un fichier CSV.
	def Surnom.importer(ligne)
		new(ligne['id'].to_i, ligne['surnom'], ligne['poids'].to_i,
		    ligne['id_pers'].to_i)
	end
	
	##
	# Retourne les surnoms d'une personne donnée
	def Surnom.id_pers(id_pers)
		return selectionner { |e| e.id_pers == id_pers }
	end
	
	## Méthode privée
	def initialize(id, surnom, poids, id_pers)
		super(id, poids)
		@surnom = surnom
		@id_pers = id_pers
	end
	
	## Donne le surnom de la personne, avec l'article donné
	def surnom(article = nil)
		return @surnom.evaluer.modif_article(article)
	end
	
	## Conversion en chaîne de caractères
	def to_s
		return self.surnom
	end
	
	## Retourne le surnom avec les paramètres donnés (article)
	def retourner(attribut = nil, parametres = nil)
		return self.surnom(parametres[0])
	end
	
end
