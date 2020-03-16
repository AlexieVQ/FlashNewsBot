require_relative 'Element.rb'
require_relative 'Info.rb'
require_relative '../String.rb'

##
# Element représentant l'action d'une Info (verbe et objet de l'information,
# "est arrêté", "a été tué" ...).
#
# Les actions sont définies dans la table +actions.csv+.

class Action < Element
	
	########################
	# CONSTANTES DE CLASSE #
	########################
	
	## <tt>"actions.csv"</tt> (String)
	FICHIER = "actions.csv"
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	# Crée une action à partir d'une ligne d'un fichier CSV.
	def Action.importer(ligne)
		new(ligne['id'].to_i, ligne['action'], ligne['poids'].to_i,
		    ligne['id_info'].to_i)
	end
	
	##
	# Retourne un Array contenant les accroches de l'Info d'identifiant donné.
	#
	# Paramètres :
	# [+id_info+]    Identifiant de l'Info (Integer, voir Action#id_info)
	def Action.id_info(id_info)
		return self.select { |e| e.id_info == id_info }
	end
	
	##
	# Lève une *RuntimeError* car il est impossible de choisir une accroche
	# aléatoirement sans connaître l'Info à laquelle elle appartient.
	def Action.elt_alea(ajout = [])
		raise "La méthode elt_alea ne peut pas être utilisée pour la classe " +
			self.to_s
	end
	
	private_class_method :new
	private_class_method :importer
	
	#############
	# ATTRIBUTS #
	#############
	
	##
	# Identifiant de l'information concernée (Integer)
	attr_reader :id_info
	
	########################
	# VARIABLES D'INSTANCE #
	########################
	
	# @action		=> Formulation de l'action (String)
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée une Action d'identifiant, de valeur et de poids donnés, liée à
	# l'Info d'identifiant donné.
	#
	# *Attention* : une Action ne peut être instanciée hors de sa classe.
	#
	# Paramètres :
	# [+id+]        Identifiant de l'action (Integer, voir Element#id)
	# [+action+]    String contenant l'action, telle que définie dans la table
	# [+poids+]     Poids défini dans la table (Integer, voir
	#               Element#poids_statique)
	# [+id_info+]   Identifiant de l'Info liée à l'action (Integer, voir
	#               Action#id_info)
	def initialize(id, action, poids, id_info)
		super(id, poids)
		@action = action
		@id_info = id_info
	end
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	##
	# Retourne l'action (String) juste après l'avoir évaluée (voir
	# String#evaluer).
	def action
		return @action.evaluer
	end
	
	##
	# Retourne l'Info correspondante.
	def info
		return Info.id(@id_info)
	end
	
	alias :to_s :action
	
	##
	# Méthode String#chercher sur le nom.
	#
	# Paramètre :
	# [+str_ou_ary+]    String ou Array de String dans lesquels chercher
	# [+taille_min+]    Nombre minimum de caractères d'un mot pour être pris en
	#                   compte (Integer)
	def chercher(str_ou_ary, taille_min = 4)
		return @action.chercher(str_ou_ary, taille_min)
	end
	
end
