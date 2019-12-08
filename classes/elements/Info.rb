require_relative 'Element.rb'
require_relative 'Action.rb'
require_relative 'Circo.rb'
require_relative 'Decla.rb'
require_relative '../String.rb'
require_relative '../Array.rb'

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
	## Structure personnalisée pour cette information
	attr :structure, false
	
	## Nom du fichier CSV correspondant
	def Info.nom_fichier
		return "infos.csv"
	end
	
	##
	# Crée une information à partir d'une ligne d'un fichier CSV.
	def Info.importer(ligne)
		actions = Action.id_info(ligne['id'].to_i)
		circos = Circo.id_info(ligne['id'].to_i)
		declas = Decla.id_info(ligne['id'].to_i)
		new(ligne['id'].to_i, actions, ligne['poids'].to_i, circos,
		    ligne['type'], declas, ligne['hashtag'], ligne['type_circo'],
		    ligne['categories'] ? ligne['categories'].split(',') : [],
		    ligne['structure'])
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
	               categories,
	               structure)
		super(id, poids)
		@actions = actions
		@circos = circos
		@type = type
		@declas = declas
		@hashtag = hashtag
		@type_circo = type_circo
		@categories = categories
		@structure = structure
	end
	
	## Retourne une action après l'avoir évaluée.
	def action
		return @actions.elt_alea.action.evaluer
	end
	
	## Retourne une circonstance après l'avoir évaluée
	def circo
		case @type_circo
		when "accuse" then
			return @circos.elt_alea(Circo.accuse).circo.evaluer
		when "est_accuse" then
			return @circos.elt_alea(Circo.est_accuse).circo.evaluer
		else
			return @circos.elt_alea([Circo.universel]).circo.evaluer
		end
	end
	
	## Retourne le type après l'avoir évalué
	def type
		return @type.evaluer
	end
	
	## Retourne une déclaration après l'avoir évaluée
	def decla
		return @declas.elt_alea($index['sujet'].declas | [Decla.elt_alea])
			.decla.evaluer
	end
	
	## Retourne un hashtag après l'avoir évalué
	def hashtag
		if @hashtag then
			return @hashtag.evaluer
		else
			return nil
		end
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
	def retourner(attribut = nil, parametres = nil)
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
			return ""
		end
	end
	
end
