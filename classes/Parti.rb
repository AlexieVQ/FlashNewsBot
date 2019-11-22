require_relative 'Element.rb'
require_relative 'String.rb'

##
# Classe représentant une organisation politique.
#
# Une organisation politique est caractérisée par son identifiant, son nom, son
# sigle, son type ('parti', 'syndicat', 'association'), son poids, ses adjectifs
# masculin et féminin, sa localité.

class Parti < Element
	
	# @nom		=> Nom du parti
	# @sigle	=> Sigle du parti
	# @adjm		=> Adjectif masculin
	# @adjf		=> Adjectif féminin
	
	## Type ('parti', 'syndicat', 'association')
	attr :type, false
	## Localité
	attr :localite, false
	
	##
	# Crée une organisation politique à partir d'une ligne d'un fichier CSV.
	def Parti.importer(ligne)
		localite = Localite.id(ligne['localite'].to_i)
		new(ligne['id'].to_i, ligne['nom'], ligne['sigle'], ligne['type'],
		    ligne['poids'].to_i, ligne['adjm'], ligne['adjf'], localite)
	end
	
	## Méthode privée
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
	
	## Donne le nom du parti, avec l'article donné après l'avoir évalué
	def nom(article = nil)
		return @nom.evaluer.modif_article(article)
	end
	
	## Donne le sigle du parti, après l'avoir évalué
	def sigle
		return @sigle.evaluer
	end
	
	## Donne l'adjectif masculin du parti, après l'avoir évalué
	def adjm
		return @adjm.evaluer
	end
	
	## Donne l'adjectif féminin du parti, après l'avoir évalué
	def adjf
		return @adjf.evaluer
	end
	
	## Donne le nom du parti
	def to_s
		return self.nom
	end
	
	##
	# Retourne l'attribut avec les paramètres demandés.  
	# Attribut possibles :
	# - "nom"
	# - "sigle"
	# - "adjm"
	# - "adjf"
	# - "localite"
	# - "type"
	# Paramètres possibles :
	# - Article pour le nom
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
