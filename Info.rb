require_relative 'Element.rb'
require_relative 'String.rb'
require_relative 'Array.rb'

##
# Classe représentant une information.
#
# Une information est caractérisée par ses actions, ses circonstances, son type,
# ses déclarations, son hashtag, son type de circonstance, ses catégories.

class Info < Element
	
	# @actions		=> Tableau d'actions
	# @circos		=> Tableau de circonstances
	# @type			=> Type (ex : "son assassinat", "sa déclaration", ...)
	# @declas		=> Tableau de déclarations
	# @hashtag		=> Hashtag
	
	## Type de circonstance
	attr :type_circo, false
	## Catégories
	attr :categories, false
	
	##
	# Pour créer une information, il faut son identifiant, le tableau de ses
	# actions, son poids, le tableau de ses circonstances, son type, le tableau
	# de ses déclarations, son hashtag, son type de circonstance et le tableau
	# de ses catégories.
	def Info.creer(id,
	               actions,
	               poids,
	               circos,
	               type,
	               declas,
	               hashtag,
	               type_circo,
	               categories)
		new(id, actions, poids, circos, type, declas, hashtag, type_circo,
		    categories)
	end
	
	## Méthode privée
	def initialize(id,
	               actions,
	               poids,
	               circos,
	               type,
	               declas,
	               hashtag,
	               type_circo,
	               categories)
		super(id, poids)
		@actions = actions
		@circos = circos
		@type = type
		@declas = declas
		@hashtag = hashtag
		@type_circo = type_circo
		@categories = categories
	end
	
	## Retourne une action après l'avoir évaluée.
	def action
		return @actions.elt_alea.evaluer
	end
	
	## Retourne une circonstance après l'avoir évaluée
	def circo
		case type_circo
		when "accuse" then
			return @circos.elt_alea($tables['circos_accuse']).evaluer
		when "est_accuse" then
			return @circos.elt_alea($tables['circos_est_accuse']).evaluer
		else
			return @circos.elt_alea([$tables['circos_uni'].elt_alea]).evaluer
		end
	end
	
	## Retourne le type après l'avoir évalué
	def type
		return @type.evaluer
	end
	
	## Retourne une déclaration après l'avoir évaluée
	def decla
		return @declas.elt_alea($index['sujet'].declas |
		                        [$tables['declas_uni'].elt_alea]).evaluer
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
		when "action" then
			return self.action
		when "circo" then
			return self.circo
		when "type" then
			return self.type
		when "decla" then
			return self.decla
		when "hashtag" then
			return self.hashtag
		else
			return self.to_s
		end
	end
	
end
