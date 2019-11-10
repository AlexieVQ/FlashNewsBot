require_relative 'Element.rb'
require_relative 'String.rb'
require_relative 'Array.rb'

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
	
	## Genre du personnage ('M' ou 'F')
	attr :genre, false
	## Catégorie du personnage
	attr :categorie, false
	## Localité du personnage
	attr :localite, false
	## Déclarations du personnage
	attr :declas, false
	
	##
	# Pour créer un personnage, il faut son identifiant un tableau contenant ses
	# noms (classe NomPers), un tableau contenant ses surnoms (classe Surnom),
	# son poids, son nom collé, son genre, sa catégorie, sa localité (classe
	# Localite) et un tableau contenant ses déclarations.
	def Pers.creer(id,
	               noms,
	               surnoms,
	               poids,
	               nom_colle,
	               genre,
	               categorie,
	               localite,
	               declas)
		new(id, noms, surnoms, poids, nom_colle, genre, categorie, localite,
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
	def surnom(article = nil)
		return @surnoms.elt_alea.surnom(article)
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
