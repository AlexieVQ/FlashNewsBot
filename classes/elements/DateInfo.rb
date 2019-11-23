require_relative 'Element.rb'
require_relative '../String.rb'

##
# Classe représentant la date d'une information.
#
# Une date est caractérisée par sa chaîne de caractère.

class DateInfo < Element
	
	# @date		=> Chaîne de caractères
	
	## Nom du fichier CSV correspondant
	def DateInfo.nom_fichier
		return "dates.csv"
	end
	
	##
	# Crée une date à partir d'une ligne d'un fichier CSV.
	def DateInfo.importer(ligne)
		new(ligne['id'].to_i, ligne['date'], ligne['poids'].to_i)
	end
	
	## Méthode privée
	def initialize(id, date, poids)
		super(id, poids)
		@date = date
	end
	
	## Donne la date stockée, après l'avoir évaluée.
	def date
		return @date.evaluer
	end
	
	## Retourne la date stockée, après l'avoir évaluée.
	def to_s
		return self.date
	end
	
end
