require_relative 'Element.rb'
require_relative 'Pers.rb'
require_relative '../String.rb'

##
# Element représentant le surnom d'un Pers.
#
# Les surnoms sont définis dans la table +surnoms.csv+.

class Surnom < Element
	
	########################
	# CONSTANTES DE CLASSE #
	########################
	
	## <tt>"surnoms.csv"</tt> (String)
	FICHIER = "surnoms.csv"
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	# Crée un surnom à partir d'une ligne d'un fichier CSV.
	def Surnom.importer(ligne)
		new(ligne['id'].to_i, ligne['surnom'], ligne['poids'].to_i,
		    ligne['id_pers'].to_i)
	end
	
	##
	# Retourne un Array contenant les surnoms du Pers d'identifiant donné.
	#
	# Paramètres :
	# [+id_pers+]   Identifiant du Pers (Integer, voir NomPers#id_info)
	def Surnom.id_pers(id_pers)
		return self.select { |e| e.id_pers == id_pers }
	end
	
	##
	# Lève une *RuntimeError* car il est impossible de choisir un surnom
	# aléatoirement sans connaître le Pers auquel il appartient.
	def Surnom.elt_alea(ajout = [])
		raise "La méthode elt_alea ne peut pas être utilisée pour la classe " +
			self.to_s
	end
	
	private_class_method :new
	private_class_method :importer
	
	#############
	# ATTRIBUTS #
	#############
	
	##
	# Identifiant du personnage concerné (Integer)
	attr_reader :id_pers
	
	########################
	# VARIABLES D'INSTANCE #
	########################
	
	# @surnom		=> Surnom du personnage (String)
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée un Surnom d'identifiant, de valeur et de poids donnés, lié au Pers
	# d'identifiant donné.
	#
	# *Attention* : un Surnom ne peut être instancié hors de sa classe.
	#
	# Paramètres :
	# [+id+]            Identifiant du nom (Integer, voir Element#id)
	# [+surnom+]        String contenant le surnom, tel que défini dans la table
	# [+poids+]         Poids défini dans la table (Integer, voir
	#                   Element#poids_statique)
	# [+id_pers+]       Identifiant du Pers lié au surnom (Integer, voir
	#                   Surnom#id_pers)
	def initialize(id, surnom, poids, id_pers)
		super(id, poids)
		@surnom = surnom
		@id_pers = id_pers
	end
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	##
	# Retourne le surnom du personnage (String) avec l'article donné juste après
	# l'avoir évaluée (voir String#evaluer).
	#
	# Paramètres :
	# [+article+]   Article à mettre au début du surnom (String, voir
	#               String#modif_article)
	def surnom(article = nil)
		return @surnom.evaluer.modif_article(article)
	end
	
	alias :to_s :surnom
	
	##
	# Retourne le Pers surnommé.
	def pers
		return Pers.id(@id_pers)
	end
	
	##
	# Retourne le résultat de Surnom#nom avec l'article contenu dans
	# <tt>parametres[0]</tt>.
	def retourner(attribut = nil, parametres = nil)
		return self.surnom(parametres[0])
	end
	
end
