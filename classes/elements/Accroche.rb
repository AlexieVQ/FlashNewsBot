require_relative 'Element.rb'
require_relative 'String.rb'

##
# Classe représentant l'accroche d'une information, héritant de la classe
# Element.
#
# Une arroche est caractérisée par sa formulation.

class Accroche < Element
	
	# @accroche		=> Formulation de l'accroche
	
	##
	# Crée une accroche à partir d'une ligne d'un fichier CSV.
	def Accroche.importer(ligne)
		new(ligne['id'].to_i, ligne['accroche'], ligne['poids'].to_i)
	end
	
	## Méthode privée
	def initialize(id, accroche, poids)
		super(id, poids)
		@accroche = accroche
	end
	
	## Donne l'accroche (une chaîne de caractères) juste après l'avoir évaluée.
	def accroche
		return @accroche.evaluer
	end
	
	## Conversion en chaîne de caractères.
	def to_s
		return self.accroche
	end
	
end
