require_relative 'Element.rb'
require_relative '../String.rb'

##
# Classe représentant l'action d'une information.
#
# Une action est caractérisée par sa chaîne de caractères.

class Action < Element
	
	# @action		=> Chaîne de caractères
	
	## Nom du fichier CSV correspondant
	def Action.nom_fichier
		return "actions.csv"
	end
	
	## Identifiant de l'information concernée
	attr :id_info, false
	
	##
	# Crée une action à partir d'une ligne d'un fichier CSV.
	def Action.importer(ligne)
		new(ligne['id'].to_i, ligne['action'], ligne['poids'].to_i,
		    ligne['id_info'].to_i)
	end
	
	##
	# Renvoie les accroches d'une info.
	def Action.id_info(id_info)
		return selectionner { |e| e.id_info == id_info }
	end
	
	##
	# Cette méthode ne peut être utilisée et lèvera une exception.
	def Action.elt_alea(ajout = [])
		raise "La méthode elt_alea ne peut pas être utilisée pour la classe " +
			self.to_s
	end
	
	## Méthode privée
	def initialize(id, action, poids, id_info)
		super(id, poids)
		@action = action
		@id_info = id_info
	end
	
	## Retourne l'action (chaîne de caractères) après l'avoir évaluée.
	def action
		return @action.evaluer
	end
	
	## Retourne l'action (chaîne de caractères) après l'avoir évaluée.
	def to_s
		return self.action
	end
	
end
