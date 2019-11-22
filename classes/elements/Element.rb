require_relative 'Array.rb'

##
# Classe représentant un élément d'une information, qui peut être un personnage,
# une situation, un lieu, une date, une déclaration...
#
# Un élément possède un identifiant dans la base de données et un poids, qui
# influence sur son choix aléatoire.

class Element
	
	## Chemin du fichier CSV correspondant
	@@chemin
	
	## Liste des éléments
	@@elements = import_table
	
	## Identifiant d'un élément
	attr :id, false
	## Poids d'un élément, accessible en lecture.
	attr :poids, false
	
	private_class_method :import_table
	private_class_method :importer
	
	##
	# Crée un élément à partir d'une ligne d'un fichier CSV.
	def Element.importer(ligne)
		raise "La classe Element ne peut être importée"
	end
	
	##
	# Importe la table des éléments depuis un fichier CSV décrit dans la
	# variable de classe chemin.
	def Element.import_table
		@@elements = []
		CSV.read(@@chemin, {:col_sep => ';', :headers => true}).each do |ligne|
			@@elements << importer(ligne)
		end
	end
	
	##
	# Accès aux éléments de la classe.
	def Element.elements
		return @@elements
	end
	
	##
	# Retourne un tableau avec les éléments qui satisfont la condition passée
	# dans le bloc.
	def Element.selectionner(&condition)
		return @@elements.inject(Array.new) do |tab, element|
			if condition.call(element) then
				tab << element
			end
		end
	end
	
	##
	# Retourne l'élément d'identifiant donné.
	def Element.id(id)
		res = selectionner { |e| e.id == id }
		return res[0]
	end
	
	##
	# Retourne un élément de la classe aléatoirement.
	def Element.elt_alea(ajout = [])
		return @@elements.elt_alea(ajout)
	end
	
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
