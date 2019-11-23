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
	
	## Nom du fichier CSV correspondant
	@@nom_fichier = "localites.csv"
	
	## Ville, région ou pays
	attr :type, false
	
	##
	# Crée une localité à partir d'une ligne d'un fichier CSV.
	def Localite.importer(ligne)
		new(ligne['id'].to_i, ligne['type'], ligne['poids'].to_i,
		    ligne['nom_en'], ligne['nom_colle'], ligne['adjm'], ligne['adjf'],
		    ligne['departement'], ligne['emoji'])
	end
	
	## Méthode privée
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
	
	## Donne le nom de la localité, avec l'article donné
	def nom(article = nil)
		if @type == "ville" && article == "en" then article = "à" end
		return @nom.evaluer.modif_article(article)
	end
	
	## Donne le nom anglais de la localité
	def nom_en
		if @nom_en then
			return @nom_en.evaluer
		else
			return @nom.evaluer.modif_article("0")
		end
	end
	
	## Donne le nom collé de la localité
	def nom_colle
		return @nom_colle.evaluer
	end
	
	## Retourne le nom collé, sans l'évaluer
	def read_nom_colle
		return @nom_colle
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
		if @departement =~ /^ \([^\(\)]*\)/ then
			return @departement.evaluer
		elsif @departement then
			return " (#{@departement.evaluer})"
		else
			return ""
		end
	end
	
	## Donne l'emoji de la localité
	def emoji
		if @emoji then
			return @emoji.evaluer
		else
			return ""
		end
	end
	
	## Conversion en chaîne de caractère
	def to_s
		return self.nom
	end
	
	##
	# Retourne l'attribut demandé avec paramètres
	# Les attributs peuvent être :
	# - "nom"
	# - "nom_en"
	# - "nom_colle"
	# - "adjm"
	# - "adjf"
	# - "departement"
	# - "emoji"
	# Les paramètres peuvent être :
	# - l'article quand on demande le nom
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
