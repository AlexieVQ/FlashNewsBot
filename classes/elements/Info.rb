require_relative '../Bot.rb'
require_relative 'Element.rb'
require_relative 'Action.rb'
require_relative 'Circo.rb'
require_relative 'Decla.rb'
require_relative '../String.rb'
require_relative '../Array.rb'

##
# Élément représentant une information, comprenant ses Action, ses Circo, son
# type ("son assassinat", "sa déclaration"...), ses Decla, son hashtag, la
# structure du status à rédiger.
#
# Les informations sont définies dans la table +infos.csv+.

class Info < Element
	
	########################
	# CONSTANTES DE CLASSE #
	########################
	
	## <tt>"infos.csv"</tt> (String)
	FICHIER = "infos.csv"
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
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
	
	private_class_method :new
	private_class_method :importer
	
	#############
	# ATTRIBUTS #
	#############
	
	##
	# Type de circonstance (String, voir Circo#type_circo)
	attr_reader :type_circo
	
	##
	# Catégories (Array de String)
	attr_reader :categories
	
	##
	# Structure personnalisée pour cette information (String)
	attr_reader :structure
	
	########################
	# VARIABLES D'INSTANCE #
	########################
	
	# @actions		=> Array d'Action
	# @circos		=> Array de Circo
	# @type			=> Type (ex : "son assassinat", "sa déclaration", ...) 
	# 				   (String)
	# @declas		=> Array de Decla
	# @hashtag		=> Hashtag (String)
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée une Info d'identifiant, de valeur, d'Action, de poids, de type, de
	# Decla, de hashtag, de type de circonstance et de catégories données.
	#
	# *Attention* : une Info ne peut être instanciée hors de sa classe.
	#
	# Paramètres :
	# [+id+]            Identifiant de l'information (Integer, voir Element#id)
	# [+actions+]       Array d'Action liées à l'information
	# [+poids+]         Poids défini dans la table (Integer, voir
	#                   Element#poids_statique)
	# [+circos+]        Array de Circo liées à l'information
	# [+type+]          Type de l'information ("son assassinat", "sa
	#                   déclaration"...)
	# [+declas+]        Array de Decla liées à l'information
	# [+hashtag+]       Hashtag de l'information (String, ou +nil+)
	# [+type_circo+]    Type de la circonstance (String, voir Circo#type_circo)
	# [+categories+]    Catégories de l'information (Array de String, voir
	#                   Info#categories)
	# [+structure+]     Structure personnalisée du status (String, voir
	#                   Info#structure)
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
	
	#######################
	# MÉTHODES D'INSTANCE #
	#######################
	
	##
	# Retourne une action (String) de l'information aléatoirement après l'avoir
	# évaluée (voir String#evaluer).
	def action
		return @actions.elt_alea.action.evaluer
	end
	
	alias :to_s :action
	
	##
	# Retourne une circonstance (String) de l'information aléatoirement (ou une
	# circonstance universelle) après l'avoir évaluée (voir String#evaluer).
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
	
	##
	# Retourne le type (String, "son assassinat", "sa déclaration"...) de
	# l'information après l'avoir évalué (voir String#evaluer).
	def type
		return @type.evaluer
	end
	
	##
	# Retourne une déclaration (String) de l'information aléatoirement (ou une
	# déclaration universelle) après l'avoir évaluée (voir String#evaluer).
	def decla
		return @declas.elt_alea(Bot.index['sujet'].declas | [Decla.elt_alea])
			.decla.evaluer
	end
	
	##
	# Retourne le hashtag (String) de l'information après l'avoir évalué (voir
	# String#evaluer), ou +nil+ si l'information n'a pas de hashtag.
	def hashtag
		if(@hashtag) then
			return @hashtag.evaluer
		else
			return nil
		end
	end
	
	##
	# Retourne un String en fonction de la valeur d'+attribut+ (String) :
	# [<tt>"action"</tt>]   Résultat de Info#action
	# [<tt>"circo"</tt>]    Résultat de Info#circo
	# [<tt>"type"</tt>]     Résultat de Info#type
	# [<tt>"decla"</tt>]    Résultat de Info#decla
	# [<tt>"hashtag"</tt>]  Résultat de Info#hashtag
	#
	# +parametres+ ignoré.
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
	
	##
	# Calcule le poids de l'information dans les choix aléatoires 
	# (Array#elt_alea) en fonction du contexte (Integer).
	#
	# Critères qui influencent le poids de l'information dans les choix
	# aléatoires :
	# * L'information a déjà été postée dans les dernières 24 heures (le poids
	#   est à +1+ et les autres critères sont ignorés)
	# * Le nombre moyen d'interactions (likes, partages, réponses) par status
	#   comprenant l'information est ajouté au poids
	def poids
		# Information déjà postée dans les dernières 24 heures
		if(Bot.compte && Bot.bdd.info_recemment_poste(self, Bot.compte) > 0)
		then
			return 1
		end
		
		poids = super
		
		# Nombre moyen d'interactions générées
		if(Bot.compte) then
			poids += Bot.bdd.interactions_pers(self, Bot.compte)
		end
		
		return poids
	end
	
end
