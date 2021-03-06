require_relative 'Element.rb'
require_relative 'Pers.rb'
require_relative '../String.rb'

##
# Element représentant le nom d'un Pers.
#
# Les noms sont définis dans la table +noms_pers.csv+.

class NomPers < Element
	
	########################
	# CONSTANTES DE CLASSE #
	########################
	
	## <tt>"noms_pers.csv"</tt> (String)
	FICHIER = "noms_pers.csv"
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	# Crée un nom à partir d'une ligne d'un fichier CSV.
	def NomPers.importer(ligne)
		new(ligne['id'].to_i, ligne['nom'], ligne['poids'].to_i,
		    ligne['id_pers'].to_i)
	end
	
	##
	# Retourne un Array contenant les noms du Pers d'identifiant donné.
	#
	# Paramètres :
	# [+id_pers+]   Identifiant du Pers (Integer, voir NomPers#id_info)
	#
	# Lève une *RuntimeError* si aucun nom n'est trouvé.
	def NomPers.id_pers(id_pers)
		noms = self.select { |e| e.id_pers == id_pers }
		if(noms.length == 0) then
			raise "Aucun nom trouvé pour le personnage d'id #{id_pers}"
		end
		return noms
	end
	
	##
	# Lève une *RuntimeError* car il est impossible de choisir un nom
	# aléatoirement sans connaître le Pers auquel il appartient.
	def NomPers.elt_alea(ajout = [])
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
	
	# @nom			=> Nom du personnage (String)
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée un NomPers d'identifiant, de valeur et de poids donnés, lié au Pers
	# d'identifiant donné.
	#
	# *Attention* : un NomPers ne peut être instancié hors de sa classe.
	#
	# Paramètres :
	# [+id+]            Identifiant du nom (Integer, voir Element#id)
	# [+nom+]           String contenant le nom, tel que défini dans la table
	# [+poids+]         Poids défini dans la table (Integer, voir
	#                   Element#poids_statique)
	# [+id_pers+]       Identifiant du Pers lié au nom (Integer, voir
	#                   NomPers#id_pers)
	def initialize(id, nom, poids, id_pers)
		super(id, poids)
		@nom = nom
		@id_pers = id_pers
	end
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	##
	# Retourne le nom du personnage (String) avec l'article donné juste après
	# l'avoir évaluée (voir String#evaluer).
	#
	# Paramètres :
	# [+article+]   Article à mettre au début du nom (String, voir
	#               String#modif_article)
	def nom(article = nil)
		return @nom.evaluer.modif_article(article)
	end
	
	alias :to_s :nom
	
	##
	# Méthode String#chercher sur le nom.
	#
	# Paramètre :
	# [+str_ou_ary+]    String ou Array de String dans lesquels chercher
	# [+taille_min+]    Nombre minimum de caractères d'un mot pour être pris en
	#                   compte (Integer)
	def chercher(str_ou_ary, taille_min = 4)
		return @nom.chercher(str_ou_ary, taille_min)
	end
	
	##
	# Retourne le Pers nommé.
	def pers
		return Pers.id(@id_pers)
	end
	
	##
	# Retourne le résultat de NomPers#nom avec l'article contenu dans
	# <tt>parametres[0]</tt>.
	def retourner(attribut = nil, parametres = nil)
		return self.nom(parametres[0])
	end
	
end
