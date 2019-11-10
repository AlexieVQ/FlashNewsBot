require_relative 'Element.rb'
require_relative 'String.rb'

##
# Classe représentant une localité (ville, région, pays).
#
# Une localité est caractérisée par son nom, son nom en anglais, son nom sans
# espaces, ses adjectifs masculin et féminin, son département, son emoji et son
# type.

class Localite < Element
	
	# @nom			=> Nom de la localité
	# @nom_en		=> Nom en anglais
	# @nom_colle	=> Nom sans espaces, ponctuation... pour hashtag
	# @adjm			=> Adjectif masculin
	# @adjf			=> Adjectif féminin
	# @departement	=> Département
	# @emoji		=> Emoji
	# @type			=> Ville, région ou pays
	
	##
	# Pour créer une localite, il faut le type, le nom, et facultativement le
	# nom en anglais, le nom collé, les adjectifs masculin et féminin, le
	# département et l'emoji.
	def Localite.creer(type,
	                   nom,
	                   nom_en,
	                   nom_colle,
	                   adjm,
	                   adjf,
	                   departement,
	                   emoji)
		new(type, nom, nom_en, nom_colle, adjm, adjf, departement, emoji)
	end
	
	## Initialisation
	def initialize(type, nom, nom_en, nom_colle, adjm, adjf, departement, emoji)
		@type = type
		@nom = nom
		@nom_en = nom_en
		@nom_colle = nom_colle
		@adjm = adjm
		@adjf = adjf
		@departement = departement
		@emoji = emoji
	end
	
	## Donne le nom de la localité, avec l'article donné
	def nom(article)
		return @nom.evaluer.modif_article(article)
	end
	
	## Donne le nom anglais de la localité
	def nom_en
		return @nom_en.evaluer
	end
	
	## Donne le nom collé de la localité
	def nom_colle
		return @nom_colle.evaluer
	end
	
	## Donne l'adjectif masculin de la localité
	def adjm
		return @adjm.evaluer
	end
	
	## Donne l'adjectif féminin de la localité
	def adjf
		return @adjf.evaluer
	end
	
	## Donne le département de la localité
	def departement
		return @departement.evaluer
	end
	
	## Donne l'emoji de la localité
	def emoji
		return @emoji.evaluer
	end
	
	## Conversion en chaîne de caractère
	def to_s
		return self.nom
	end
	
	## Retourne l'attribut demandé avec paramètres
	# Les attributs peuvent être :
	# - nom
	# - nom_en
	# - nom_colle
	# - adjm
	# - adjf
	# - departement
	# - emoji
	# Les paramètres peuvent être :
	# - l'article quand on demande le nom
	def retourner(attribut, parametres)
		case attribut
		when "nom"
			return self.nom(parametres[0])
		when "nom_en"
			return self.nom_en
		when "nom_colle"
			return self.nom_colle
		when "adjm"
			return self.adjm
		when "adjf"
			return self.adjf
		when "departement"
			return self.departement
		when "emoji"
			return self.emoji
		else
			return self.nom
		end
	end
	
end
