require_relative 'Element.rb'
require_relative '../String.rb'
require_relative '../Enumerable.rb'

##
# Element représentant une circonstance, liée à une information, universelle
# (utilisable quelque soit le contexte), ou utilisable quand le sujet accuse
# quelqu'un ou est accusé.
#
# Les circonstances sont définies dans la table +circos.csv+.

class Circo < Element
	
	########################
	# CONSTANTES DE CLASSE #
	########################
	
	## <tt>"circos.csv"</tt> (String)
	FICHIER = "circos.csv"
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	# Crée une circonstance à partir d'une ligne d'un fichier CSV.
	def Circo.importer(ligne)
		new(ligne['id'].to_i, ligne['circo'], ligne['poids'].to_i,
		    ligne['type'], ligne['id_info'].to_i)
	end
	
	##
	# Retourne un Array contenant les Circo universelles.
	def Circo.universels
		return self.select { |e| e.type_circo == "universel" }
	end
	
	##
	# Retourne une Circo universelle choisie au hasard.
	def Circo.universel
		return universels.elt_alea
	end
	
	##
	# Retourne un Array de Circo où le sujet est accusé.
	def Circo.est_accuse
		return self.select { |e|
			["accusation", "est_accuse"].include? e.type_circo
		}
	end
	
	##
	# Retourne un Array de Circo où le sujet accuse l'objet.
	def Circo.accuse
		return self.select { |e|
			 ["accusation", "accuse"].include? e.type_circo
		}
	end
	
	##
	# Retourne un Array de Circo de type donné.
	#
	# Paramètres :
	# [+type+]  Type de la circonstance (String, voir Circo#type_circo).
	#           <tt>"specifique"</tt> n'est pas reconnu.
	#
	# Lève une *RuntimeError* si le +type+ n'est pas reconnu.
	def Circo.type(type)
		case type
		when "universel"
			return Circo.universels
		when "accuse"
			return Circo.accuse
		when "est_accuse"
			return Circo.est_accuse
		when "accusation"
			return Circo.accuse | Circo.est_accuse
		else
			raise "Type de circonstance #{type} non-reconnu"
		end
	end
	
	##
	# Retourne un Array contenant les circonstances de l'Info d'identifiant
	# donné.
	#
	# Paramètres :
	# [+id_info+]   Identifiant de l'Info (Integer, voir Circo#id_info)
	def Circo.id_info(id_info)
		return self.select { |e| e.id_info == id_info }
	end
	
	##
	# Retourne une Circo universelle aléatoirement.
	#
	# Paramètres :
	# [+ajout+] Éléments à ajouter dans la recherche (Array, vide par défaut)
	def Circo.elt_alea(ajout = [])
		return universels.elt_alea(ajout)
	end
	
	##
	# Retourne un Sring représentant une circonstance de type donné par
	# <tt>parametres[0]</tt> aléatoirement.
	#
	# Par défaut, retourne une une circonstance universelle.
	def Circo.retourner(attribut = nil, parametres = ["universel"])
		element = Circo.type(parametres[0]).elt_alea
		return retourner_elt(element, attribut, parametres)
	end
	
	private_class_method :new
	private_class_method :importer
	
	#############
	# ATTRIBUTS #
	#############
	
	##
	# Type de circonstance (String). Valeurs possibles :
	# [<tt>"specifique"</tt>]    S'applique à l'Info liée.
	# [<tt>"universel"</tt>]     Circonstances universelles.
	# [<tt>"accuse"</tt>]    Le sujet accuse l'objet.
	# [<tt>"est_accuse"</tt>]    Le sujet est accusé par l'objet.
	# [<tt>"accusation"</tt>]    Regroupe <tt>"accuse"</tt> et
	#                            <tt>"est_accuse"</tt>.
	attr_reader :type_circo
	
	##
	# Identifiant de l'Info rattachée (Integer ou +nil+)
	attr_reader :id_info
	
	########################
	# VARIABLES D'INSTANCE #
	########################
	
	# @circo		=> Chaîne de caractères
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée une Circo d'identifiant, de valeur, de poids et de type donnés, liée
	# à l'Info d'identifiant donné.
	#
	# *Attention* : une Circo ne peut être instanciée hors de sa classe.
	#
	# Paramètres :
	# [+id+]            Identifiant de la circonstance (Integer, voir
	#                   Element#id)
	# [+circo+]         String contenant la circonstance, telle que définie dans
	#                   la table
	# [+poids+]         Poids défini dans la table (Integer, voir
	#                   Element#poids_statique)
	# [+type_circo+]    Type de la circonstance (String, voir Circo#type_circo)
	# [+id_info+]       Identifiant de l'Info liée à la circonstance (Integer,
	#                   voir Circo#id_info ; ou +nil+ par défaut)
	def initialize(id, circo, poids, type_circo, id_info = nil)
		super(id, poids)
		@circo = circo
		@type_circo = type_circo
		@id_info = id_info
	end
	
	#######################
	# MÉTHODES D'INSTANCE #
	#######################
	
	##
	# Retourne la circonstance (String) après l'avoir évaluée (voir
	# String#evaluer).
	def circo
		return @circo.evaluer
	end
	
	alias :to_s :circo
	
end
