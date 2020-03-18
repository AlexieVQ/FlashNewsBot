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
		    ligne['id_info_sujet'].to_i, ligne['id_info_objet'].to_i,
		    ligne['id_info_autre'].to_i, ligne['id_pers'].to_i)
	end
	
	##
	# Retourne un Array contenant les déclarations de l'Info d'identifiant
	# donné pouvant être dite par le sujet de l'information.
	#
	# Paramètres :
	# [+id_info+]    Identifiant de l'Info (Integer, voir Decla#id_info_sujet)
	def Decla.id_info_sujet(id_info)
		return self.select { |e| e.id_info_sujet == id_info }
	end
	
	##
	# Retourne un Array contenant les déclarations de l'Info d'identifiant
	# donné pouvant être dite par l'objet de l'information.
	#
	# Paramètres :
	# [+id_info+]    Identifiant de l'Info (Integer, voir Decla#id_info_objet)
	def Decla.id_info_objet(id_info)
		return self.select { |e| e.id_info_objet == id_info }
	end
	
	##
	# Retourne un Array contenant les déclarations de l'Info d'identifiant
	# donné pouvant être dite par un personnage tierce.
	#
	# Paramètres :
	# [+id_info+]    Identifiant de l'Info (Integer, voir Decla#id_info)
	def Decla.id_info_autre(id_info)
		return self.select { |e| e.id_info_autre == id_info }
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
		tab = self.select { |e|
			e.id_info_sujet == 0 && e.id_info_objet == 0 &&
				e.id_info_autre == 0 && e.id_pers == 0
		}
		return tab.elt_alea(ajout)
	end
	
	private_class_method :new
	private_class_method :importer
	
	#############
	# ATTRIBUTS #
	#############
	
	##
	# Identifiant de l'information rattachée dont le déclarant est sujet
	# (Integer, ou +nil+)
	attr_reader :id_info_sujet
	
	##
	# Identifiant de l'information rattachée dont le déclarant est objet
	# (Integer, ou +nil+)
	attr_reader :id_info_objet
	
	##
	# Identifiant de l'information rattachée dont le déclarant est un personnage
	# tierce (Integer, ou +nil+)
	attr_reader :id_info_autre
	
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
	# [+id_info_sujet+] Identifiant de l'Info liée à la déclaration dont le
	#                   déclarant est le sujet (Integer, voir
	#                   Decla#id_info_sujet ; ou +nil+ par défaut)
	# [+id_info_objet+] Identifiant de l'Info liée à la déclaration dont le
	#                   déclarant est objet(Integer, voir Decla#id_info_objet ;
	#                   ou +nil+ par défaut)
	# [+id_info_autre+] Identifiant de l'Info liée à la déclaration dont le
	#                   déclarant est tierce (Integer, voir
	#                   Decla#id_info_autre ; ou +nil+ par défaut)
	# [+id_pers+]       Identifiant du Pers lié à la déclaration (Integer, voir
	#                   Decla#id_pers ; ou +nil+ par défaut)
	def initialize(id,
	               decla,
	               poids,
	               id_info_sujet = nil,
	               id_info_objet = nil,
	               id_info_autre = nil,
	               id_pers = nil)
		super(id, poids)
		@decla = decla
		@id_info_sujet = id_info_sujet
		@id_info_objet = id_info_objet
		@id_info_autre = id_info_autre
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
	# Retourne l'Info associée à la déclaration dont le déclarant est sujet, ou
	# +nil+ si aucune n'est liée.
	def info_sujet
		return @id_info_sujet ? Info.id(@id_info_sujet) : nil
	end
	
	##
	# Retourne l'Info associée à la déclaration dont le déclarant est objet, ou
	# +nil+ si aucune n'est liée.
	def info_objet
		return @id_info_objet ? Info.id(@id_info_objet) : nil
	end
	
	##
	# Retourne l'Info associée à la déclaration dont le déclarant est tierce, ou
	# +nil+ si aucune n'est liée.
	def info_autre
		return @id_info_autre ? Info.id(@id_info_autre) : nil
	end
	
	##
	# Retourne le Pers associé à la déclaration, ou +nil+ si aucun n'est lié.
	def pers
		return @id_pers ? Pers.id(@id_pers) : nil
	end
	
	alias :to_s :decla
	
end
