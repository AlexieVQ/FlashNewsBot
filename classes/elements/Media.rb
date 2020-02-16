require_relative 'Element.rb'
require_relative '../String.rb'

##
# Element représentant un média.
#
# Les médias sont définis dans +medias.csv+.

class Media < Element
	
	########################
	# CONSTANTES DE CLASSE #
	########################
	
	## <tt>"medias.csv"</tt> (String)
	FICHIER = "medias.csv"
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	# Crée un média à partir d'une ligne d'un fichier CSV.
	def Media.importer(ligne)
		new(ligne['id'].to_i, ligne['nom'], ligne['poids'].to_i)
	end
	
	private_class_method :new
	private_class_method :importer
	
	########################
	# VARIABLES D'INSTANCE #
	########################
	
	# @nom		=> Nom du média (String)
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée un Media d'identifiant, de valeur et de poids donnés.
	#
	# *Attention* : un Media ne peut être instanciée hors de sa classe.
	#
	# Paramètres :
	# [+id+]        Identifiant du média (Integer, voir Element#id)
	# [+nom+]       String contenant le nom du média, tel que défini dans la
	#               table
	# [+poids+]     Poids défini dans la table (Integer, voir
	#               Element#poids_statique)
	def initialize(id, nom, poids)
		super(id, poids)
		@nom = nom
	end
	
	#######################
	# MÉTHODES D'INSTANCE #
	#######################
	
	##
	# Retourne le nom du média (String) avec l'article donné après l'avoir
	# évalué (voir String#evaluer).
	#
	# Paramètres :
	# [+article+]   Article à mettre en début du nom (String, voir
	#               String#modif_article)
	def nom(article = nil)
		return @nom.evaluer.modif_article(article)
	end
	
	alias :to_s :nom
	
	##
	# Si l'attribut <tt>"nom"</tt> est donné, retourne le résultat de Media#nom
	# avec <tt>parametres[0]</tt> comme article. Sinon, retourne une chaîne
	# vide.
	def retourner(attribut = nil, parametres = nil)
		case attribut
		when "nom" then
			return self.nom(parametres[0])
		else
			return ""
		end
	end
	
end
