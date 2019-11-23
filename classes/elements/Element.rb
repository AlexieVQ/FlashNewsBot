require 'csv'
require_relative '../Array.rb'

##
# Classe représentant un élément d'une information, qui peut être un personnage,
# une situation, un lieu, une date, une déclaration...
#
# Un élément possède un identifiant dans la base de données et un poids, qui
# influence sur son choix aléatoire.

class Element
	
	# @elements		=> Éléments de la classe
	
	## Identifiant d'un élément
	attr :id, false
	## Poids d'un élément, accessible en lecture.
	attr :poids, false
	
	## Chemin du dossier contenant les fichiers CSV
	def Element.chemin
		return $dir + "/tables/"
	end
	
	## Nom du fichier CSV correspondant
	def Element.nom_fichier
		raise "La classe Element n'a pas de fichier"
	end
	
	##
	# Crée un élément à partir d'une ligne d'un fichier CSV.
	def Element.importer(ligne)
		raise "La classe Element ne peut être importée"
	end
	
	##
	# Importe la table des éléments depuis un fichier CSV décrit dans la
	# variable de classe chemin.
	def Element.elements
		unless defined?(@elements) then
			@elements = []
			CSV.read(chemin + nom_fichier,
					{:col_sep => ';', :headers => true}).each do |ligne|
				@elements << importer(ligne)
			end
		end
		return @elements
	end
	
	##
	# Retourne un tableau avec les éléments qui satisfont la condition passée
	# dans le bloc.
	def Element.selectionner(&condition)
		return elements.select { |e| condition.call(e) }
	end
	
	##
	# Retourne l'élément d'identifiant donné. Initialise la table au premier
	# appel.
	def Element.id(id)
		res = selectionner { |e| e.id == id }
		return res[0]
	end
	
	##
	# Retourne un élément de la classe aléatoirement.
	def Element.elt_alea(ajout = [])
		return elements.elt_alea(ajout)
	end
	
	##
	# Retourne un élément pour l'attribut et les paramètres donnés.
	def Element.retourner(attribut = nil, parametres = nil)
		return retourner_elt(elements.elt_alea, attribut, parametres)
	end
	
	##
	# Retourne un élément en lui passant l'attribut et les paramètres donnés.
	def Element.retourner_elt(element, attribut, parametres)
		if attribut && attribut != "" then
			return element.retourner(attribut, parametres)
		else
			return element
		end
	end
	
	private_class_method :retourner_elt
	
	## Pour initialiser un élément il faut son identifiant et son poids.
	def initialize(id, poids)
		@id = id
		@poids = poids
	end
	
	## Convertie l'élément en chaîne de caractère
	def to_s
		raise "L'élément est vide"
	end
	
	## Retourne la valeur demandée
	def retourner(attribut = nil, parametres = nil)
		return self.to_s
	end
	
end
