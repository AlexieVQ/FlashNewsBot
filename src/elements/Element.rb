require 'csv'
require_relative '../Bot.rb'
require_relative '../Array.rb'

##
# Superclasse abstraite représentant un élément d'une information.
#
# Les différents types d'éléments sont :
# * Accroche ("BREAKING NEWS", "ALERTE INFO" ...)
# * Pers (une instance par personnage comprenant ses noms, surnoms ...)
#   * NomPers (nom d'un personnage)
#   * Surnom (surnom d'un personnage, "le Président", "le journaliste" ...)
# * Info (une instance par information, comprenant ses différentes formulations)
#   * Action (verbe et objet de l'information, "est arrêté", "a été tué" ...)
#   * Circo (circonstance d'une information, peut être générale)
#   * Decla (déclaration du personnage dans le cadre d'une information, peut
#     être générale ou liée à un personnage)
# * DateInfo (date d'une information, "ce matin", "ce soir", "lundi dernier"
#   ...)
# * Lieu (lieu d'une information, "à son domicile", "dans son bureau", "à Lyon",
#   ...)
# * Localite (ville, pays ou région)
# * Media (presse écrite, télévisée ou en ligne)
# * Parti (parti politique ou organisation syndicale)

class Element
	
	#######################
	# VARIABLES DE CLASSE #
	#######################
	
	# @elements		=> Array contenant les éléments de la classe
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	##
	# Retourne le chemin du dossier (String) contenant les fichiers .csv
	# représentant les tables.
	#
	# Exemple de retour :
	#	"/home/foo/FlashNewsBot/tables/"
	def Element.chemin
		return Bot.dir + "/tables/"
	end
	
	##
	# Retourne le nom du fichier contenant la table (String), sans son chemin.
	# Les sous-classes d'Element doivent définir la constante +FICHIER+ (String
	# contenant le nom du fichier sans son chemin).
	#
	# Exemple de retour :
	#	"accroche.csv"
	# 
	# Lève une *RuntimeError* si appelée sur la classe Element.
	def Element.nom_fichier
		return self::FICHIER
	end
	
	##
	# Retourne un Array contenant tous les éléments de la classe.
	#
	# Lorsqu'appelée pour la première fois, construit importe les éléments
	# depuis leur fichier .csv (voir Element#nom_fichier).
	#
	# Lève une *RuntimeError* si appelée sur la classe Element, ou si plusieurs
	# éléments possèdent le même +id+ dans une table.
	def Element.elements
		unless(defined?(@elements)) then
			@elements = []
			CSV.read(chemin + nom_fichier,
					{:col_sep => ';', :headers => true}).each do |ligne|
				element = importer(ligne)
				if(@elements.any? { |e| e.id == element.id }) then
					raise "L'id #{element.id} est attribué plusieurs fois " +
					      "dans la table #{self::FICHIER}"
				end
				@elements << element
			end
		end
		return @elements
	end
	
	##
	# Retourne un Array contenant les éléments de la classe pour lesquels le
	# bloc +condition+ renvoie +true+.
	#
	# Lève une *RuntimeError* si appelée sur la classe Element.
	def Element.selectionner(&condition)
		return elements.select { |e| condition.call(e) }
	end
	
	##
	# Retourne l'élément d'identifiant donné.
	#
	# Paramètres :
	# [+id+]    Identifiant de l'élément (Integer, voir Element#id)
	#
	# Lève une *RuntimeError* si appelée sur la classe Element.
	def Element.id(id)
		res = selectionner { |e| e.id == id }
		return res[0]
	end
	
	##
	# Retourne un élément de la classe aléatoirement.
	#
	# Paramètres :
	# [+ajout+] Éléments à ajouter dans la recherche (Array, vide par défaut)
	#
	# Lève une *RuntimeError* si appelée sur la classe Element.
	def Element.elt_alea(ajout = [])
		return elements.elt_alea(ajout)
	end
	
	##
	# Retourne un String pour l'attribut et les paramètres donnés. Comportement
	# différent selon la classe.
	#
	# Exemple d'utilisation :
	# 	{pers.surnom(de)}
	# dans un fichier .csv va produire l'appel suivant :
	# 	Pers.retourner("surnom", ["de"])
	# et retournera le surnom d'un personnage tiré au hasard, commençant par un
	# article contracté.
	#
	# Paramètres :
	# [+attribut+]      Mot-clef se trouvant juste après le +.+, +_surnom_+ dans
	#                   l'exemple (String, +nil+ par défaut)
	# [+parametres+]    Array de mots-clefs se trouvant entre parenthèses,
	#                   +_de_+ dans l'exemple (+nil+ par défaut)
	#
	# Lève une *RuntimeError* si appelée sur la classe Element.
	def Element.retourner(attribut = nil, parametres = nil)
		return retourner_elt(elt_alea, attribut, parametres)
	end
	
	# Retourne un élément en lui passant l'attribut et les paramètres donnés.
	def Element.retourner_elt(element, attribut, parametres)
		if(attribut && attribut != "") then
			return element.retourner(attribut, parametres)
		else
			return element
		end
	end
	
	private_class_method :retourner_elt
	private_class_method :new
	
	#############
	# ATTRIBUTS #
	#############
	
	##
	# Identifiant d'un élément (Integer).
	#
	# Chaque élément à un identifiant unique à sa classe, mais pas à l'ensemble
	# des éléments.
	attr_reader :id
	
	##
	# Poids d'un élément (Integer) tel que décrit dans la table. Utilisé pour
	# calculer dans le calcul du poids en fonction du contexte (Element#poids).
	attr_reader :poids_statique
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée un élément d'identifiant et de poids donnés.
	#
	# *Attention* : la classe Element ne peut être instanciée.
	#
	# Paramètres :
	# [+id+]    Identifiant de l'élément, voir Element#id (Integer)
	# [+poids+] Poids de l'élément tel que défini dans la table, voir
	#           Element#poids_statique (Integer)
	def initialize(id, poids)
		@id = id
		@poids_statique = poids
	end
	
	#######################
	# MÉTHODES D'INSTANCE #
	#######################
	
	##
	# Retourne un String pour l'attribut et les paramètres donnés. Comportement 
	# différent selon la classe.
	#
	# Par défaut retourne juste le résultat de +to_s+, indépendamment de
	# l'attribut et des paramètres donnés.
	#
	# Exemple d'utilisation :
	# 	{p1=pers}{p1.surnom(de)}
	# dans un fichier .csv va produire l'appel suivant :
	# 	p1 = Pers.retourner()
	# 	p1.retourner("surnom", ["de"])
	# et retournera le surnom du personnage +p1+, commençant par un article
	# contracté.
	#
	# Paramètres :
	# [+attribut+]      Mot-clef se trouvant juste après le +.+, +_surnom_+ dans
	#                   l'exemple (String, +nil+ par défaut)
	# [+parametres+]    Array de mots-clefs se trouvant entre parenthèses,
	#                   +_de_+ dans l'exemple (+nil+ par défaut)
	def retourner(attribut = nil, parametres = nil)
		return self.to_s
	end
	
	##
	# Calcule le poids de l'élément dans les choix aléatoires (Array#elt_alea)
	# en fonction du contexte (Integer).
	#
	# Critères qui influencent le poids de l'élément dans les choix aléatoires :
	# * L'élément est déjà présent dans le status (poids à +1+)
	def poids
		return self.deja_present? ? 1 : @poids_statique
	end
	
	##
	# Teste si l'élément est déjà présent dans le status (présence dans l'index,
	# voir Bot::index).
	def deja_present?
		return Bot.index.any? { |tuple| tuple[1] == self }
	end
	
	##
	# Teste si deux éléments sont les mêmes.
	def ==(elt)
		return self.class == elt.class && self.id == elt.id
	end
	
end
