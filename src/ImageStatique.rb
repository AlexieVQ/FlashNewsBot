##
# Image telle que _Flash Info_, pouvant être associée à n'importe quel status,
# contenue dans <tt>assets/</tt>.
#
# Toutes les méthodes du module Enumerable peuvent être utilisées sur la classe
# pour lister les images disponibles.

class ImageStatique
	
	class << self
		include Enumerable
	end
	
	#######################
	# VARIABLES DE CLASSE #
	#######################
	
	# @images	=> Array d'ImageStatique
	
	########################
	# CONSTANTES DE CLASSE #
	########################
	
	## Fichiers à utiliser (Array de Hash)
	FICHIERS = [
		{nom: "flash_info.jpg", description: "Flash Info"},
		{nom: "breaking_news_2.jpg", description: "Breaking News"},
		{nom: "breaking_news_3.jpg", description: "Breaking News"},
		{nom: "flash_info_nyc.jpg", description: "Flash Info"},
		{nom: "flash_special_1.jpg", description: "Flash Spécial"}
	]
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	##
	# Itère sur toutes les images statiques.
	def ImageStatique.each
		if(@images.nil?) then
			@images = FICHIERS.map { |tuple|
				new(tuple[:nom], tuple[:description])
			}
		end
		@images.each { |image| yield image }
	end
	
	private_class_method :new
	
	#############
	# ATTRIBUTS #
	#############
	
	##
	# Nom du fichier (String)
	attr_reader :nom_fichier
	
	alias :id :nom_fichier
	
	##
	# Description de l'image (String)
	attr_reader :description
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée une image contenue dans le fichier de nom donné présent dans le
	# dossier <tt>assets/</tt> et de description donnée.
	#
	# *Attention* : la classe ImageStatique ne peut être instanciée depuis une
	# autre classe. Utiliser les méthodes de classe et du module Enumerable pour
	# accéder à ses objets.
	#
	# Paramètre :
	# [+nom+]           Nom du fichier (String)
	# [+description+]   Description de l'image (String)
	def initialize(nom, description)
		@nom_fichier = nom
		@description = description
	end
	
	#######################
	# MÉTHODES D'INSTANCE #
	#######################
	
	##
	# Retourne un String de la forme <tt>[_Description_ _nom du fichier_]</tt>.
	def to_s
		return "[#{@description} #{@nom_fichier}]"
	end
	
	##
	# Retourne le chemin du fichier (String).
	def chemin
		return "#{Bot.dir}/assets/#{@nom_fichier}"
	end
	
	##
	# Retourne le fichier (File) de l'image.
	def fichier
		return File.open(self.chemin, "rb")
	end
	
end
