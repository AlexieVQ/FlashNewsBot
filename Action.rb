require_relative 'Element.rb'
require_relative 'String.rb'

##
# Classe représentant l'action d'une information.
#
# Une action est caractérisée par sa chaîne de caractères.

class Action < Element
	
	# @action		=> Chaîne de caractères
	
	##
	# Pour créer une action, il faut son identifiant, sa chaîne de caractères et
	# son poids.
	def Action.creer(id, action, poids)
		new(id, action, poids)
	end
	
	## Méthode privée
	def initialize(id, action, poids)
		super(id, poids)
		@action = action
	end
	
	## Retourne l'action (chaîne de caractères) après l'avoir évaluée.
	def action
		return @action.evaluer
	end
	
	## Retourne l'action (chaîne de caractères) après l'avoir évaluée.
	def to_s
		return self.action
	end
	
end
