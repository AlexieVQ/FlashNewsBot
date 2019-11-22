require_relative 'Element.rb'
require_relative 'String.rb'

##
# Classe représentant le lieu d'une information.
#
# Un lieu est caractérisé par sa chaîne de caractère.

class Lieu < Element
	
	# @lieu		=> Chaîne de caractères
	
	##
	# Crée un lieu à partir d'une ligne d'un fichier CSV.
	def Lieu.importer(ligne)
		new(ligne['id'].to_i, ligne['lieu'], ligne['poids'].to_i)
	end
	
	## Méthode privée
	def initialize(id, lieu, poids)
		super(id, poids)
		@lieu = lieu
	end
	
	## Donne le lieu stocké, après l'avoir évalué.
	def lieu
		return @lieu.evaluer
	end
	
	## Retourne le lieu stocké, après l'avoir évalué.
	def to_s
		return self.lieu
	end
	
end
