require_relative 'Element.rb'
require_relative 'String.rb'

##
# Classe représentant la déclaration d'un personnage.
#
# Une déclaration est caractérisée par sa chaîne de caractères.

class Decla < Element
	
	# @decla		=> Chaîne de caractères
	
	## Identifiant de l'information rattachée
	attr :id_info, false
	## Identifiant de la personne rattachée
	attr :id_pers, false
	
	##
	# Pour créer une déclaration, il faut son identifiant, sa chaîne de
	# caractères et son poids.
	def Decla.creer(id, decla, poids)
		new(id, decla, poids)
	end
	
	##
	# Crée une déclaration à partir d'une ligne d'un fichier CSV.
	def Decla.importer(ligne)
		new(ligne['id'].to_i, ligne['decla'], ligne['poids'].to_i,
		    ligne['id_info'].to_i, ligne['id_pers'].to_i)
	end
	
	## Méthode privée
	def initialize(id, decla, poids, id_info = nil, id_pers = nil)
		super(id, poids)
		@decla = decla
		@id_info = id_info
		@id_pers = id_pers
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
