require_relative 'Element.rb'
require_relative 'String.rb'

##
# Classe représentant la date d'une information.
#
# Une date est caractérisée par sa chaîne de caractère.

class DateInfo < Element
	
	# @date		=> Chaîne de caractères
	
	##
	# Pour créer une date, il nous faut son identifiant, sa chaîne de caractères
	# et son poids.
	def DateInfo.creer(id, date, poids)
		new(id, date, poids)
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
