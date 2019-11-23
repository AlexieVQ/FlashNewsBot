require_relative 'Element.rb'
require_relative 'String.rb'

##
# Classe représentant les circonstances d'une information.
#
# Une circonstance est caractérisée par sa chaîne de caractères.

class Circo < Element
	
	# @circo		=> Chaîne de caractères
	
	## Nom du fichier CSV correspondant
	@@nom_fichier = "circos.csv"
	
	## Type de circonstance
	attr :type_circo, false
	## Identifiant de l'information rattachée
	attr :id_info, false
	
	##
	# Crée une circonstance à partir d'une ligne d'un fichier CSV.
	def Circo.importer(ligne)
		new(ligne['id'].to_i, ligne['circo'], ligne['poids'].to_i,
		    ligne['type_circo'], ligne['id_info'].to_i)
	end
	
	## Méthode privée
	def initialize(id, circo, poids, type_circo, id_info = nil)
		super(id, poids)
		@circo = circo
		@type_circo = type_circo
		@id_info = id_info
	end
	
	## Retourne la circonstance (chaîne de caractères) après l'avoir évaluée.
	def circo
		return @circo.evaluer
	end
	
	## Retourne la circonstance (chaîne de caractères) après l'avoir évaluée.
	def to_s
		return self.circo
	end
	
end
