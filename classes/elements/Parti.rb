require_relative 'Element.rb'
require_relative 'Localite.rb'
require_relative '../String.rb'

##
# Element représentant un parti politique ou une organisation syndicale.
#
# Les organisations politiques sont définies dans +partis.csv+.

class Parti < Element
	
	########################
	# CONSTANTES DE CLASSE #
	########################
	
	## <tt>"partis.csv"</tt> (String)
	FICHIER = "partis.csv"
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	# Crée une organisation politique à partir d'une ligne d'un fichier CSV.
	def Parti.importer(ligne)
		localite = Localite.id(ligne['localite'].to_i)
		new(ligne['id'].to_i, ligne['nom'], ligne['sigle'], ligne['type'],
		    ligne['poids'].to_i, ligne['adjm'], ligne['adjf'], localite)
	end
	
	##
	# Retourne un Array de Parti de types donnés.
	#
	# Paramètres :
	# [+types+] Array des types demandés (String, voir Parti#type)
	def Parti.types(types)
		return selectionner { |e| types.include?(e.type) }
	end
	
	##
	# Retourne un String représentant l'organisation demandée.
	# Si le tableau +parametres+ contient les types des organisations demandées
	# (voir Parti#type), retourne une organisation d'un de ces types. Sinon
	# retourne une organisation au hasard.
	#
	# +attribut+ est ignoré.
	def Parti.retourner(attribut = nil, parametres = nil)
		if ["parti", "syndicat", "association"].include?(parametres[0]) then
			element = Parti.types(parametres).elt_alea
		else
			element = Parti.elt_alea
		end
		return retourner_elt(element, attribut, parametres)
	end
	
	private_class_method :new
	private_class_method :importer
	
	#############
	# ATTRIBUTS #
	#############
	
	##
	# Type d'organisation (String) :
	# * <tt>"parti"</tt>
	# * <tt>"syndicat"</tt>
	# * <tt>"association"</tt>
	attr_reader :type
	
	##
	# Localité de l'organisation (Localite)
	attr_reader :localite
	
	########################
	# VARIABLES D'INSTANCE #
	########################
	
	# @nom		=> Nom du parti (String)
	# @sigle	=> Sigle du parti (String)
	# @adjm		=> Adjectif masculin (String)
	# @adjf		=> Adjectif féminin (String)
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée un Parti d'identifiant, de nom, de sigle, de type, de poids,
	# d'adjectifs et de localité données.
	#
	# *Attention* : un Parti ne peut être instanciée hors de sa classe.
	#
	# Paramètres :
	# [+id+]            Identifiant de l'organisation (Integer, voir Element#id)
	# [+nom+]           Nom de l'organisation (String)
	# [+sigle+]         Sigle de l'organisation, intégrable dans un hashtag
	#                   (String)
	# [+type+]          Type d'organisation (String, voir Parti#type)
	# [+poids+]         Poids de l'organisation (Integer, voir Element#poids)
	# [+adjm+]          Adjectif masculin lié à l'organisation (String)
	# [+adjf+]          Adjectif féminin lié à l'organisation (String)
	# [+localite+]      Localité de l'organisation (Localite, voir
	#                   Parti#localite)
	def initialize(id, nom, sigle, type, poids, adjm, adjf, localite)
		super(id, poids)
		@nom = nom
		@sigle = sigle
		@type = type
		@poids = poids
		@adjm = adjm
		@adjf = adjf
		@localite = localite
	end
	
	#######################
	# MÉTHODES D'INSTANCE #
	#######################
	
	##
	# Retourne le nom de l'organisation (String) avec l'article donné après
	# l'avoir évalué (voir String#evaluer).
	#
	# Paramètres :
	# [+article+]   Article à mettre au début du nom (String, voir
	#               String#modif_article)
	def nom(article = nil)
		return @nom.evaluer.modif_article(article)
	end
	
	alias :to_s :nom
	
	##
	# Retourne le sigle du parti (String) après l'avoir évalué (voir
	# String#evaluer).
	def sigle
		return @sigle.evaluer
	end
	
	##
	# Retourne l'adjectif masculin de l'organisation (String), après l'avoir
	# évalué (voir String#evaluer).
	def adjm
		return @adjm.evaluer
	end
	
	##
	# Retourne l'adjectif féminin de l'organisation (String), après l'avoir
	# évalué (voir String#evaluer).
	def adjf
		return @adjf.evaluer
	end
	
	##
	# Retourne un String en fonction de la valeur d'+attribut+ (String) :
	# [<tt>"nom"</tt>]          Résultat de Parti#nom
	# [<tt>"sigle"</tt>]        Résultat de Parti#sigle
	# [<tt>"adjm"</tt>]         Résultat de Parti#adjm
	# [<tt>"adjf"</tt>]         Résultat de Parti#adjf
	# [<tt>"localite"</tt>]     Résultat de Parti#localite
	# [<tt>"type"</tt>]         Résultat de Parti#type
	#
	# Lorsque l'attribut est <tt>"nom"</tt>, <tt>parametre[0]</tt> doit contenir
	# l'article demandé (String, voir String#modif_article).
	#
	# Si aucun attribut n'est donné, renvoie une chaîne vide.
	def retourner(attribut = nil, parametres = nil)
		case attribut
		when "nom" then
			return self.nom(parametres[0])
		when "sigle" then
			return self.sigle
		when "adjm" then
			return self.adjm
		when "adjf" then
			return self.adjf
		when "localite" then
			return @localite
		when "type" then
			return @type
		else
			return ""
		end
	end
	
end
