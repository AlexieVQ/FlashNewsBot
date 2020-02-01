require_relative 'Element.rb'
require_relative '../String.rb'

##
# Element représentant la date d'une information ("aujourd'hui", "ce matin"...).
#
# Les dates sont définiées dans +dates.csv+.

class DateInfo < Element
	
	########################
	# CONSTANTES DE CLASSE #
	########################
	
	## <tt>"dates.csv"</tt> (String)
	FICHIER = "dates.csv"
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	# Crée une date à partir d'une ligne d'un fichier CSV.
	def DateInfo.importer(ligne)
		new(ligne['id'].to_i, ligne['date'], ligne['poids'].to_i)
	end
	
	private_class_method :new
	private_class_method :importer
	
	########################
	# VARIABLES D'INSTANCE #
	########################
	
	# @date		=> String
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée une DateInfo d'identifiant, de valeur et de poids donnés.
	#
	# *Attention* : une DateInfo ne peut être instanciée hors de sa classe.
	#
	# Paramètres :
	# [+id+]        Identifiant de la date (Integer, voir Element#id)
	# [+date+]      String contenant la date, telle que définie dans la table
	# [+poids+]     Poids de la date (Integer, voir Element#poids)
	def initialize(id, date, poids)
		super(id, poids)
		@date = date
	end
	
	#######################
	# MÉTHODES D'INSTANCE #
	#######################
	
	##
	# Retourne la date (String) juste après l'avoir évaluée (voir
	# String#evaluer).
	def date
		return @date.evaluer
	end
	
	alias :to_s :date
	
end
