require_relative 'Element.rb'

##
# Element représentant une réponse à une mention du bot.
#
# Les réponses sont choisies en fonction des mots-clefs contenus dans la
# mention. Elles sont définies dans la table +reponses.csv+.

class Reponse < Element
	
	########################
	# CONSTANTES DE CLASSE #
	########################
	
	## <tt>"reponses.csv"</tt> (String)
	FICHIER = "reponses.csv"
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	# Crée une Reponse à partir d'une ligne du fichier CSV.
	def Reponse.importer(ligne)
		new(ligne['id'].to_i, ligne['mots_clefs'].split(','), ligne['reponse'],
		    ligne['poids'].to_i)
	end
	
	##
	# Retourne une Reponse choisie aléatoirement en fonction des mots-clefs
	# présents dans la mention.
	#
	# Si aucune réponse ne convient, retourne +nil+.
	#
	# Paramètres :
	# [+mention+]	Mention à laquelle répondre (String)
	def Reponse.repondre(mention)
		begin
			return self.select { |reponse|
				reponse.mots_clefs.any? { |mot_clef| mention.include? mot_clef }
			}.elt_alea
		rescue RuntimeError
			return nil
		end
	end
	
	private_class_method :new
	private_class_method :importer
	
	#############
	# ATTRIBUTS #
	#############
	
	##
	# Mots-clefs auxquels la réponse répond (Array de String)
	attr_reader :mots_clefs
	
	##
	# Texte de la réponse (String)
	attr_reader :reponse
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée une Reponse d'identifiant, de valeur et de poids donnés répondant aux
	# mots-clefs donnés.
	#
	# *Attention* : une Reponse ne peut être instanciée hors de sa classe.
	#
	# Paramètres :
	# [+id+]            Identifiant de la réponse (Integer, voir Element#id)
	# [+mots_clefs+]    Mots-clefs auxquels la réponse répond (Array de String)
	# [+reponse+]       Texte de la réponse (String)
	# [+poids+]         Poids de la réponse (Integer)
	def initialize(id, mots_clefs, reponse, poids)
		super(id, poids)
		@mots_clefs = mots_clefs
		@reponse = reponse
	end
	
	#######################
	# MÉTHODES D'INSTANCE #
	#######################
	
	alias :to_s :reponse
	
end
