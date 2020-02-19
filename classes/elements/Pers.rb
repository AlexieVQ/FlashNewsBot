require_relative 'Element.rb'
require_relative 'NomPers.rb'
require_relative 'Surnom.rb'
require_relative 'Localite.rb'
require_relative 'Decla.rb'
require_relative '../Bot.rb'
require_relative '../String.rb'
require_relative '../Array.rb'

##
# Element représentant un personnage, comprenant ses NomPers, ses Surnom, son
# genre, son nom sans espaces, sa catégorie, sa localité, ses Decla.
#
# Les personnages sont définis dans la table +pers.csv+.

class Pers < Element
	
	########################
	# CONSTANTES DE CLASSE #
	########################
	
	## <tt>"pers.csv"</tt> (String)
	FICHIER = "pers.csv"
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	# Crée un personnage à partir d'une ligne d'un fichier CSV.
	def Pers.importer(ligne)
		noms = NomPers.id_pers(ligne['id'].to_i)
		surnoms = Surnom.id_pers(ligne['id'].to_i)
		localite = Localite.id(ligne['localite'].to_i)
		declas = Decla.id_pers(ligne['id'].to_i)
		new(ligne['id'].to_i, noms, surnoms, ligne['poids'].to_i,
		    ligne['nom_colle'], ligne['genre'], ligne['categorie'], localite,
		    declas)
	end
	
	##
	# Retourne un Array de Pers de genre donné.
	#
	# Paramètres :
	# [+genre+] Genre des personnages (String, voir Pers#genre)
	def Pers.genre(genre)
		return selectionner { |e| e.genre == genre }
	end
	
	##
	# Retourne un String représentant la localité demandée.
	#
	# Si un attribut est donné, un personnage est choisi aléatoirement et
	# l'attribut est utilisé par Pers#retourner. Sinon, retourne un personnage
	# de genre contenu dans <tt>parametres[0]</tt> (voir Pers#genre).
	def Pers.retourner(attribut = nil, parametres = nil)
		if attribut && attribut != "" || parametres[0] == nil then
			element = elements.elt_alea
		elsif parametres[0] then
			element = genre(parametres[0]).elt_alea
		end
		return retourner_elt(element, attribut, parametres)
	end
	
	private_class_method :new
	private_class_method :importer
	
	#############
	# ATTRIBUTS #
	#############
	
	##
	# Genre du personnage (String) : <tt>"M"</tt> ou <tt>"F"</tt>.
	attr_reader :genre
	
	##
	# Catégorie du personnage (String)
	attr_reader :categorie
	
	##
	# Localité du personnage (Localite ou +nil+)
	attr_reader :localite
	
	##
	# Déclarations du personnage (Array de Decla)
	attr_reader :declas
	
	########################
	# VARIABLES D'INSTANCE #
	########################
	
	# @noms			=> Tableau des noms (Array de String)
	# @surnoms		=> Tableau des surnoms (Array de String)
	# @nom_colle	=> Nom collé pour hashtag (String) 
	# @surnomme		=> Nombre de fois que le surnom a été donné. (Integer)
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée un Pers d'identifiant, de noms, de surnoms, de poids, de nom sans
	# espaces, de genre, de catégorie, de localité et de déclarations données.
	#
	# *Attention* : un Pers ne peut être instancié hors de sa classe.
	#
	# Paramètres :
	# [+id+]            Identifiant du personnage (Integer, voir Element#id)
	# [+noms+]          Noms du personnage (Array de NomPers)
	# [+surnoms+]       Surnoms du personnage (Array de Surnom)
	# [+poids+]         Poids défini dans la table (Integer, voir
	#                   Element#poids_statique)
	# [+nom_colle+]     Nom du personnage, sans espace (String)
	# [+genre+]         Genre du personnage (String, voir Pers#genre)
	# [+categorie+]     Catégorie du personnage (String, voir Pers#categorie)
	# [+localite+]      Localité du personnage (Localite)
	# [+declas+]        Déclarations du personnage (Array de Decla)
	def initialize(id,
	               noms,
	               surnoms,
	               poids,
	               nom_colle,
	               genre,
	               categorie,
	               localite,
	               declas)
		super(id, poids)
		@noms = noms
		@surnoms = surnoms
		@nom_colle = nom_colle
		@genre = genre
		@categorie = categorie
		@localite = localite
		@declas = declas
		@surnomme = 0
	end
	
	#######################
	# MÉTHODES D'INSTANCE #
	#######################
	
	##
	# Retourne le nom du personnage (String) avec l'article donné après l'avoir
	# évalué (voir String#evaluer).
	#
	# Paramètres :
	# [+article+]   Article à mettre au début du nom (String, voir
	#               String#modif_article)
	def nom(article = nil)
		return @noms.elt_alea.nom(article)
	end
	
	alias :to_s :nom
	
	##
	# Retourne le surnom du personnage (String) avec l'article donné après
	# l'avoir évalué (voir String#evaluer).
	#
	# Si le surnom a déjà été donné, retourne le pronom (correspondant à
	# l'article donné).
	#
	# Paramètres :
	# [+article+]   Article à mettre au début du surnom (String, voir
	#               String#modif_article)
	def surnom(article = nil)
		unless(@surnomme > 0) then
			@surnomme += 1
			return @surnoms.elt_alea.surnom(article)
		else
			case @genre
			when 'M' then
				if article =~ /(de|à)/i then return "#{article} lui"
				else return "il"
				end
			when 'F' then
				if article =~ /de/i then return "d’elle"
				elsif article =~ /à/i then return "à elle"
				else return "elle"
				end
			else raise "Genre #{@genre} non connu pour #{@nom_colle}"
			end
		end
	end
	
	##
	# Retourne le nom sans espace du personnage (String), pouvant être intégré
	# dans un hashtag, après l'avoir évalué (voir String#evaluer).
	def nom_colle
		return @nom_colle.evaluer
	end
	
	##
	# Retourne un String en fonction de la valeur d'+attribut+ (String) :
	# [<tt>"nom"</tt>]          Résultat de Pers#nom
	# [<tt>"surnom"</tt>]       Résultat de Pers#surnom
	# [<tt>"nom_colle"</tt>]    Résultat de Pers#nom_colle
	# [<tt>"localite"</tt>]     Résultat de Pers#localite
	#
	# Lorsque l'attribut est <tt>"nom"</tt>, <tt>parametre[0]</tt> doit contenir
	# l'article demandé (String, voir String#modif_article).
	#
	# Si aucun attribut n'est donné, renvoie une chaîne vide.
	def retourner(attribut = nil, parametres = nil)
		case attribut
		when "nom" then
			return self.nom(parametres[0])
		when "surnom" then
			return self.surnom(parametres[0])
		when "nom_colle" then
			return self.nom_colle
		when "localite" then
			return @localite
		else
			return ""
		end
	end
	
	##
	# Calcule le poids du personnage dans les choix aléatoires (Array#elt_alea)
	# en fonction du contexte (Integer).
	#
	# Critères qui influencent le poids du personnage dans les choix
	# aléatoires :
	# * Le personnage a déjà été posté dans les dernières 24 heures (le poids
	#   est à +1+ et les autres critères sont ignorés)
	# * Le personnage est dans une des catégories de l'information (le poids est
	#   multiplié par 20)
	# * Le personnage est dans la même catégorie que le sujet (le poids est
	#   multiplié par 10)
	# * Le personnage est de la même localité que la localité principale du
	#   status (+loc_principale+) (le poids est multiplié par 20)
	def poids
		# Personnage déjà posté dans les dernières 24 heures
		if(Bot.compte && Bot.bdd.pers_recemment_poste(self, Bot.compte) > 0)
		then
			return 1
		end
		
		poids = super
		
		if(Bot.index['info']) then
			# Catégories de l'information
			if(Bot.index['info'].categories.length > 0) then
				if(Bot.index['info'].categories.include?(@categorie)) then
					poids *= 20
				end
				
			# Sinon catégorie du sujet
			elsif(Bot.index['sujet']) then
				if(Bot.index['sujet'].categorie == @categorie)
					poids *= 10
				end
			end
		end
		
		# Localité de l'information
		if(Bot.index['loc_principale'] && @localite) then
			if(Bot.index['loc_principale'] == @localite) then
				poids *= 20
			end
		end
		return poids
	end
	
end
