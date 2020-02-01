require_relative 'Element.rb'
require_relative '../String.rb'

##
# Element représentant le lieu d'une information ("à son domicile", "à
# Paris"...).
#
# Les lieux sont définis dans +lieux.csv+.

class Lieu < Element
	
	########################
	# CONSTANTES DE CLASSE #
	########################
	
	## <tt>"lieux.csv"</tt> (String)
	FICHIER = "lieux.csv"
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	# Crée un lieu à partir d'une ligne d'un fichier CSV.
	def Lieu.importer(ligne)
		new(ligne['id'].to_i, ligne['lieu'], ligne['poids'].to_i)
	end
	
	private_class_method :new
	private_class_method :importer
	
	########################
	# VARIABLES D'INSTANCE #
	########################
	
	# @lieu		=> String
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée un Lieu d'identifiant, de valeur et de poids donnés.
	#
	# *Attention* : un Lieu ne peut être instanciée hors de sa classe.
	#
	# Paramètres :
	# [+id+]        Identifiant du lieu (Integer, voir Element#id)
	# [+lieu+]      String contenant le lieu, tel que défini dans la table
	# [+poids+]     Poids du lieu (Integer, voir Element#poids)
	def initialize(id, lieu, poids)
		super(id, poids)
		@lieu = lieu
	end
	
	#######################
	# MÉTHODES D'INSTANCE #
	#######################
	
	##
	# Retourne le lieu (String) juste après l'avoir évaluée (voir
	# String#evaluer).
	def lieu
		return @lieu.evaluer
	end
	
	alias :to_s :lieu
	
end
