require_relative 'Element.rb'
require_relative '../String.rb'

##
# Element représentant une ville, un pays ou une région.
#
# Les localités sont définies dans +localites.csv+.

class Localite < Element
	
	########################
	# CONSTANTES DE CLASSE #
	########################
	
	## <tt>"localites.csv"</tt> (String)
	FICHIER = "localites.csv"
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	# Crée une localité à partir d'une ligne d'un fichier CSV.
	def Localite.importer(ligne)
		new(ligne['id'].to_i, ligne['type'], ligne['nom'], ligne['poids'].to_i,
		    ligne['nom_en'], ligne['nom_colle'], ligne['adjm'], ligne['adjf'],
		    ligne['departement'], ligne['emoji'])
	end
	
	##
	# Retourne un Array de Localite de types donnés.
	#
	# Paramètres :
	# [+types+] Array des types demandés (String, voir Localite#type)
	def Localite.types(types)
		return selectionner { |e| types.include?(e.type) }
	end
	
	##
	# Retourne la Localite de nom collé donné.
	#
	# Paramètres :
	# [+nom_colle+] Nom, sans espaces, de la localité (String, non évalué avec
	#               String#evaluer)
	def Localite.nom_colle(nom_colle)
		return selectionner { |e| nom_colle == e.read_nom_colle }
	end
	
	##
	# Retourne un String représentant la localité demandée.
	#
	# Le tableau +parametres+ peut contenir :
	# * les types des localités demandées (voir Localite#type),
	# * ou le nom collé de la localité demandée (appel de Localite::nom_colle).
	# Si +parametres+ est vide, retourne une localité au hasard.
	#
	# +attribut+ est ignoré.
	def Localite.retourner(attribut = nil, parametres = nil)
		if(["ville", "pays", "region"].include?(parametres[0])) then
			element = types(parametres).elt_alea
		elsif(parametres && parametres.length != 0) then
			element = nom_colle(parametres[0]).elt_alea
		else
			element = elements.elt_alea
		end
		return retourner_elt(element, attribut, parametres)
	end
	
	private_class_method :new
	private_class_method :importer
	
	#############
	# ATTRIBUTS #
	#############
	
	##
	# Type de la localité (String) :
	# * <tt>"ville"</tt>
	# * <tt>"pays"</tt>
	# * <tt>"region"</tt>
	attr_reader :type
	
	########################
	# VARIABLES D'INSTANCE #
	########################
	
	# @nom			=> Nom de la localité (String)
	# @nom_en		=> Nom en anglais (String)
	# @nom_colle	=> Nom sans espaces, ponctuation... pour hashtag (String)
	# @adjm			=> Adjectif masculin (String)
	# @adjf			=> Adjectif féminin (String)
	# @departement	=> Département (String)
	# @emoji		=> Emoji (String)
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée une Localite d'identifiant, de type, de nom, de poids, de nom en
	# anglais, de nom sans espaces, d'adjectifs, de département et d'emojis
	# donnés.
	#
	# *Attention* : une Localite ne peut être instanciée hors de sa classe.
	#
	# Paramètres :
	# [+id+]            Identifiant de la localité (Integer, voir Element#id)
	# [+type+]          Type de localité (String, voir Localite#type)
	# [+nom+]           Nom de la localité, en français (String)
	# [+poids+]         Poids défini dans la table (Integer, voir
	#                   Element#poids_statique)
	# [+nom_en+]        Nom de la localité, en anglais (String ou +nil+)
	# [+nom_colle+]     Nom de la localité, sans espace (String)
	# [+adjm+]          Adjectif masculin lié à la localité (String)
	# [+adjf+]          Adjectif féminin lié à la localité (String)
	# [+departement+]   Département de la localité (String ou +nil+)
	# [+emoji+]         Drapeau de la localité en emoji (String ou +nil+)
	def initialize(id,
	               type,
	               nom,
	               poids,
	               nom_en,
	               nom_colle,
	               adjm,
	               adjf,
	               departement,
	               emoji)
		super(id, poids)
		@type = type
		@nom = nom
		@nom_en = nom_en
		@nom_colle = nom_colle
		@adjm = adjm
		@adjf = adjf
		@departement = departement
		@emoji = emoji
	end
	
	#######################
	# MÉTHODES D'INSTANCE #
	#######################
	
	##
	# Retourne le nom de la localité (String) avec l'article donné après l'avoir
	# évalué (voir String#evaluer).
	#
	# Paramètres :
	# [+article+]   Article à mettre au début du nom (String, voir
	#               String#modif_article)
	def nom(article = nil)
		if(@type == "ville" && article == "en") then article = "à" end
		return @nom.evaluer.modif_article(article)
	end
	
	alias :to_s :nom
	
	##
	# Retourne le nom de la localité en anglais (String) après l'avoir évalué
	# (voir String#evaluer).
	#
	# Si la localité n'a pas de nom en anglais, retourne le nom en français sans
	# article.
	def nom_en
		if(@nom_en) then
			return @nom_en.evaluer
		else
			return @nom.evaluer.modif_article("0")
		end
	end
	
	##
	# Retourne le nom sans espace de la localité (String), pouvant être intégré
	# dans un hashtag, après l'avoir évalué (voir String#evaluer).
	def nom_colle
		return @nom_colle.evaluer
	end
	
	##
	# Retourne le nom collé sans l'évaluer (String).
	def read_nom_colle
		return @nom_colle
	end
	
	##
	# Retourne l'adjectif masculin de la localité (String), après l'avoir évalué
	# (voir String#evaluer).
	def adjm
		return @adjm.evaluer
	end
	
	##
	# Retourne l'adjectif féminin de la localité (String), après l'avoir évalué
	# (voir String#evaluer).
	def adjf
		return @adjf.evaluer
	end
	
	##
	# Retourne le département de la localité (String), entre parenthèses
	# précédées d'une espace. Par exemple, <tt>" (72)"</tt>. Si la localité n'a
	# pas de département, renvoie une chaîne vide.
	#
	# Le département est pensé pour être intégré de cette manière :
	#	La ville {v=localite(ville)}{v.nom(de)}{v.departement}.
	# Afin de produire ces résultats :
	#	La ville de Paris (75).
	#	La ville de Shanghai.
	def departement
		if(@departement =~ /^ \([^\(\)]*\)/) then
			return @departement.evaluer
		elsif(@departement) then
			return " (#{@departement.evaluer})"
		else
			return ""
		end
	end
	
	##
	# Retourne l'emoji de la localité (String), après l'avoir évalué (voir
	# String#evaluer). Si la localité n'a pas d'émoji, retourne une chaîne vide.
	def emoji
		if(@emoji) then
			return @emoji.evaluer
		else
			return ""
		end
	end
	
	##
	# Retourne un String en fonction de la valeur d'+attribut+ (String) :
	# [<tt>"nom"</tt>]          Résultat de Localite#nom
	# [<tt>"nom_en"</tt>]       Résultat de Localite#nom_en
	# [<tt>"nom_colle"</tt>]    Résultat de Localite#nom_colle
	# [<tt>"adjm"</tt>]         Résultat de Localite#adjm
	# [<tt>"adjf"</tt>]         Résultat de Localite#adjf
	# [<tt>"departement"</tt>]  Résultat de Localite#departement
	# [<tt>"emoji"</tt>]        Résultat de Localite#emoji
	#
	# Lorsque l'attribut est <tt>"nom"</tt>, <tt>parametre[0]</tt> doit contenir
	# l'article demandé (String, voir String#modif_article).
	#
	# Si aucun attribut n'est donné, renvoie une chaîne vide.
	def retourner(attribut = nil, parametres = nil)
		case attribut
		when "nom" then
			return self.nom(parametres[0])
		when "nom_en" then
			return self.nom_en
		when "nom_colle" then
			return self.nom_colle
		when "adjm" then
			return self.adjm
		when "adjf" then
			return self.adjf
		when "departement" then
			return self.departement
		when "emoji" then
			return self.emoji
		else
			return ""
		end
	end
	
end
