require_relative 'Element.rb'
require_relative 'Localite.rb'
require_relative '../String.rb'

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
	
	## Nom du fichier CSV correspondant
	def Parti.nom_fichier
		return "partis.csv"
	end
	
	##
	# Crée une organisation politique à partir d'une ligne d'un fichier CSV.
	def Parti.importer(ligne)
		localite = Localite.id(ligne['localite'].to_i)
		new(ligne['id'].to_i, ligne['nom'], ligne['sigle'], ligne['type'],
		    ligne['poids'].to_i, ligne['adjm'], ligne['adjf'], localite)
	end
	
	##
	# Retourne les partis de types donnés.
	def Parti.types(types)
		return selectionner { |e| types.include?(e.type) }
	end
	
	##
	# Retourne un élément pour l'attribut et les paramètres donnés.
	def Parti.retourner(attribut = nil, parametres = nil)
		if ["parti", "syndicat", "association"].include?(parametres[0]) then
			element = Parti.types(parametres).elt_alea
		else
			element = Parti.elt_alea
		end
		return retourner_elt(element, attribut, parametres)
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
