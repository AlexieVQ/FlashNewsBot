require_relative 'Element.rb'
require_relative 'NomPers.rb'
require_relative 'Surnom.rb'
require_relative 'Localite.rb'
require_relative 'Decla.rb'
require_relative '../String.rb'
require_relative '../Array.rb'

##
# Classe représentant un personnage.
#
# Un personnage est caractérisé par ses noms, ses surnoms, son nom collé (pour
# les hashtags), son genre, sa catégorie, sa localité (un objet Localite) et ses
# déclarations.

class Pers < Element
	
	# @noms			=> Tableau des noms
	# @surnoms		=> Tableau des surnoms
	# @nom_colle	=> Nom collé pour hashtag
	# @surnomme		=> Nombre de fois que le surnom a été donné.
	
	## Nom du fichier CSV correspondant
	@@nom_fichier = "pers.csv"
	
	## Genre du personnage ('M' ou 'F')
	attr :genre, false
	## Catégorie du personnage
	attr :categorie, false
	## Localité du personnage
	attr :localite, false
	## Déclarations du personnage
	attr :declas, false
	
	##
	# Crée un personnage à partir d'une ligne d'un fichier CSV.
	def Personnage.importer(ligne)
		noms = Nom.id_pers(ligne['id'].to_i)
		surnoms = Surnom.id_pers(ligne['id'].to_i)
		localite = Localite.id(ligne['localite'].to_i)
		declas = Decla.id_pers(ligne['id'].to_i)
		new(ligne['id'].to_i, noms, surnoms, ligne['poids'].to_i,
		    ligne['nom_colle'], ligne['genre'], ligne['categorie'], localite,
		    declas)
	end
	
	## Méthode privée
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
	
	##
	# Renvoie un nom de la personne aléatoirement, après l'avoir évalué et
	# modifié son article.
	def nom(article = nil)
		return @noms.elt_alea.nom(article)
	end
	
	##
	# Renvoie un surnom de la personne aléatoirement, après l'avoir évalué et
	# modifié son article.  
	# Si un surnom a déjà été donné, renvoie le pronom.
	def surnom(article = nil)
		unless @surnomme > 0 then
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
	# Renvoie le nom collé de la personne après l'avoir évalué.
	def nom_colle
		return @nom_colle.evaluer
	end
	
	##
	# Convertie le personnage en chaîne de caractère (son nom)
	def to_s
		return self.nom
	end
	
	##
	# Retourne un attribut du personnage avec les paramètres demandés.  
	# Attributs possibles :
	# - "nom"
	# - "surnom"
	# - "nom_colle"
	# - "localite"
	# Paramètres :
	# - article pour le nom ou le surnom
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
	
end
