require_relative 'Element.rb'
require_relative 'String.rb'
require_relative 'Array.rb'

##
# Classe représentant une information.
#
# Une information est caractérisée par ses actions, ses circonstances, son type,
# ses déclarations, son hashtag, son type de circonstance.

class Info < Element
	
	# @actions		=> Tableau d'actions
	# @circos		=> Tableau de circonstances
	# @type			=> Type (ex : "son assassinat", "sa déclaration", ...)
	# @declas		=> Tableau de déclarations
	# @hashtag		=> Hashtag
	
	## Type de circonstance
	attr :type_circo, false
	
	##
	# Pour créer une information, il faut son identifiant, le tableau de ses
	# actions, son poids, le tableau de ses circonstances, son type, le tableau
	# de ses déclarations, son hashtag, son type de circonstance.
	def Info.creer(id,
	               actions,
	               poids,
	               circos,
	               type,
	               declas,
	               hashtag,
	               type_circo)
		new(id, actions, poids, circos, type, declas, hashtag, type_circo)
	end
	
	## Méthode privée
	def initialize(id,
	               actions,
	               poids,
	               circos,
	               type,
	               declas,
	               hashtag,
	               type_circo)
		super(id, poids)
		@actions = actions
		@circos = circos
		@type = type
		@declas = declas
		@hashtag = hashtag
		@type_circo = type_circo
	end
	
	## Retourne une action après l'avoir évaluée.
	def action
		return @actions.elt_alea.evaluer
	end
	
	## Retourne une circonstance après l'avoir évaluée
	def circo
		return @circos.elt_alea.evaluer
	end
	
	## Retourne le type après l'avoir évalué
	def type
		return @type.evaluer
	end
	
	## Retourne une déclaration après l'avoir évaluée
	def decla
		return @declas.elt_alea.evaluer
	end
	
	## Retourne un hashtag après l'avoir évalué
	def hashtag
		return @hashtag.evaluer
	end
	
	## Retourne une action après l'avoir évaluée.
	def to_s
		return self.action
	end
	
	##
	# Retourne l'attribut avec les paramètres demandés.  
	# Attributs possibles :
	# - "action"
	# - "circo"
	# - "type"
	# - "decla"
	# - "hashtag"
	def retourner(attribut, parametres)
		case attribut
		when "action"
			return self.action
		when "circo"
			return self.circo
		when "type"
			return self.type
		when "decla"
			return self.decla
		when "hashtag"
			return self.hashtag
		else
			return self.to_s
		end
	end
	
end
