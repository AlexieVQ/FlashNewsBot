require 'open-uri'
require_relative '../Bot.rb'
require_relative 'Element.rb'

##
# Element contenant le lien vers une image. L'image peut être liée à un Pers ou
# une Info.
#
# Les liens vers les images sont stockés dans la table +images.csv+.

class Image < Element
	
	########################
	# CONSTANTES DE CLASSE #
	########################
	
	## <tt>"images.csv"</tt> (String)
	FICHIER = "images.csv"
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	# Crée une Image à partir d'une ligne d'un fichier CSV.
	def Image.importer(ligne)
		new(ligne['id'].to_i, ligne['description'], ligne['url'],
		    ligne['format'], ligne['poids'].to_i, ligne['id_pers'].to_i,
		    ligne['id_info'].to_i)
	end
	
	##
	# Retourne un Array contenant les images de l'Info d'identifiant donné.
	#
	# Paramètres :
	# [+id_info+]    Identifiant de l'Info (Integer, voir Image#id_info)
	def Image.id_info(id_info)
		return selectionner { |e| e.id_info == id_info }
	end
	
	##
	# Retourne un Array contenant les images du Pers d'identifiant donné.
	#
	# Paramètres :
	# [+id_info+]    Identifiant du personnage (Integer, voir Image#id_pers)
	def Image.id_pers(id_pers)
		return selectionner { |e| e.id_pers == id_pers }
	end
	
	##
	# Lève une *RuntimeError* car il est impossible de choisir une image
	# aléatoirement sans connaître le Pers ou l'Info à laquelle elle appartient.
	def Image.elt_alea(ajout = [])
		raise "La méthode elt_alea ne peut pas être utilisée pour la classe " +
			self.to_s
	end
	
	private_class_method :new
	private_class_method :importer
	
	#############
	# ATTRIBUTS #
	#############
	
	##
	# Description de l'image (utilisé comme texte alternatif, String)
	attr_reader :description
	
	##
	# URL de l'image (String)
	attr_reader :url
	
	##
	# Format de l'image (String)
	attr_reader :format
	
	##
	# Identifiant de l'information rattachée (Integer, ou +nil+)
	attr_reader :id_info
	
	##
	# Identifiant du personnage rattachée (Integer, ou +nil+)
	attr_reader :id_pers
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée une Image d'identifiant, de valeur et de poids donnés, liée à
	# l'Info ou au Pers d'identifiant donné.
	#
	# *Attention* : une Image ne peut être instanciée hors de sa classe.
	#
	# Paramètres :
	# [+id+]            Identifiant de l'image (Integer, voir Element#id)
	# [+description+]   Description de l'image (Sring, voir Image#description)
	# [+url+]           URL de l'image (String)
	# [+format+]        Format de l'image (String)
	# [+poids+]         Poids défini dans la table (Integer, voir
	#                   Element#poids_statique)
	# [+id_pers+]       Identifiant du Pers lié à la l'image (Integer, voir
	#                   Image#id_pers ; ou +nil+)
	# [+id_info+]       Identifiant de l'Info liée à l'image (Integer, voir
	#                   Image#id_info ; ou +nil+)
	def initialize(id, description, url, format, poids, id_pers, id_info = nil)
		super(id, poids)
		@description = description
		@url = url
		@format = format
		@id_info = id_info
		@id_pers = id_pers
	end
	
	#######################
	# MÉTHODES D'INSTANCE #
	#######################
	
	##
	# Retourne un String de la forme <tt>[_Description_ _url_]</tt>.
	def to_s
		return "[#{@description} #{@url}]"
	end
	
	##
	# Retourne le chemin du fichier, qu'il existe ou non (String).
	def chemin
		return "#{Bot.dir}/assets/cache/#{@id}.#{@format}"
	end
	
	##
	# Télécharge l'image dans le dossier <tt>assets/cache/</tt> avec son
	# Element#id en nom de fichier et son format en extension (exemple :
	# <tt>assets/cache/45.jpg</tt>).
	#
	# Si l'image existe déjà, elle est écrasée.
	#
	# Retourne +self+.
	def telecharger
		File.open(self.chemin, "wb") { |fichier|
			open(@url, "rb") { |distant| fichier.write(distant.read) }
		}
		return self
	end
	
	##
	# Teste si le fichier existe dans le répertoire <tt>assets/cache</tt>.
	def telecharge?
		return File.exist? self.chemin
	end
	
end
