require_relative 'Element.rb'
require_relative 'Info.rb'
require_relative 'Pers.rb'
require_relative '../String.rb'

##
# Element représentant la déclaration du sujet à propos de l'information qui le
# concerne. Elle peut être liée à une information, à un personnage ou
# indépendante.
#
# Les déclarations sont définies dans la table +declas.csv+.

class Decla < Element
	
	########################
	# CONSTANTES DE CLASSE #
	########################
	
	## <tt>"declas.csv"</tt> (String)
	FICHIER = "declas.csv"
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	# Crée une déclaration à partir d'une ligne d'un fichier CSV.
	def Decla.importer(ligne)
		new(ligne['id'].to_i, ligne['decla'], ligne['poids'].to_i,
		    ligne['id_info'].to_i, ligne['id_pers'].to_i)
	end
	
	##
	# Retourne un Array contenant les déclarations de l'Info d'identifiant
	# donné.
	#
	# Paramètres :
	# [+id_info+]    Identifiant de l'Info (Integer, voir Decla#id_info)
	def Decla.id_info(id_info)
		return self.select { |e| e.id_info == id_info }
	end
	
	##
	# Retourne un Array contenant les déclarations du Pers d'identifiant
	# donné.
	#
	# Paramètres :
	# [+id_info+]    Identifiant du personnage (Integer, voir Decla#id_pers)
	def Decla.id_pers(id_pers)
		return self.select { |e| e.id_pers == id_pers }
	end
	
	##
	# Retourne une Decla universelle aléatoirement.
	#
	# Paramètres :
	# [+ajout+] Éléments à ajouter dans la recherche (Array, vide par défaut)
	def Decla.elt_alea(ajout = [])
		tab = self.select { |e| e.id_info == 0 && e.id_pers == 0 }
		return tab.elt_alea(ajout)
	end
	
	private_class_method :new
	private_class_method :importer
	
	#############
	# ATTRIBUTS #
	#############
	
	##
	# Identifiant de l'information rattachée (Integer, ou +nil+)
	attr_reader :id_info
	##
	# Identifiant du personnage rattachée (Integer, ou +nil+)
	attr_reader :id_pers
	
	########################
	# VARIABLES D'INSTANCE #
	########################
	
	# @decla		=> String
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée une Decla d'identifiant, de valeur et de poids donnés, liée à
	# l'Info ou au Pers d'identifiant donné.
	#
	# *Attention* : une Decla ne peut être instanciée hors de sa classe.
	#
	# Paramètres :
	# [+id+]            Identifiant de la déclaration (Integer, voir Element#id)
	# [+decla+]         String contenant la déclaration, telle que définie dans
	#                   la table
	# [+poids+]         Poids défini dans la table (Integer, voir
	#                   Element#poids_statique)
	# [+id_info+]       Identifiant de l'Info liée à la déclaration (Integer,
	#                   voir Decla#id_info ; ou +nil+ par défaut)
	# [+id_pers+]       Identifiant du Pers lié à la déclaration (Integer, voir
	#                   Decla#id_pers ; ou +nil+ par défaut)
	def initialize(id, decla, poids, id_info = nil, id_pers = nil)
		super(id, poids)
		@decla = decla
		@id_info = id_info
		@id_pers = id_pers
	end
	
	#######################
	# MÉTHODES D'INSTANCE #
	#######################
	
	##
	# Retourne la déclaration (String) après l'avoir évaluée (voir
	# String#evaluer).
	def decla
		return @decla.evaluer
	end
	
	##
	# Retourne l'Info associée à la déclaration, ou +nil+ si aucune n'est liée.
	def info
		return @id_info ? Info.id(@id_info) : nil
	end
	
	##
	# Retourne le Pers associé à la déclaration, ou +nil+ si aucun n'est lié.
	def pers
		return @id_pers ? Pers.id(@id_pers) : nil
	end
	
	alias :to_s :decla
	
end
