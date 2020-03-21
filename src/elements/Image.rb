require 'open-uri'
require_relative '../Bot.rb'
require_relative 'Element.rb'
require_relative 'Info.rb'
require_relative 'Pers.rb'

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
		return self.select { |e| e.id_info == id_info }
	end
	
	##
	# Retourne un Array contenant les images du Pers d'identifiant donné.
	#
	# Paramètres :
	# [+id_info+]    Identifiant du personnage (Integer, voir Image#id_pers)
	def Image.id_pers(id_pers)
		return self.select { |e| e.id_pers == id_pers }
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
	# Retourne l'Info associée à l'image, ou +nil+ si aucune n'est liée.
	def info
		return @id_info ? Info.id(@id_info) : nil
	end
	
	##
	# Retourne le Pers associé à l'image, ou +nil+ si aucun n'est lié.
	def pers
		return @id_pers ? Pers.id(@id_pers) : nil
	end
	
	##
	# Retourne un avertissement de contenu pour l'image (String, vide ou +nil+
	# si aucun avertissement).
	def cw
		if(!@cw.to_s.empty?) then
			return super
		elsif(self.info) then
			return self.info.cw
		elsif(self.pers) then
			return self.pers.cw
		else
			return nil
		end
	end
	
	##
	# Teste si l'image a un avertissement de contenu (voir Image#cw).
	def cw?
		return !@cw.to_s.empty? || self.info && self.info.cw? ||
			self.pers && self.pers.cw?
	end
	
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
	# Retourne le chemin du fichier (String).
	#
	# Paramètres :
	# [+ecraser+]   +true+ si le fichier doit être écrasé s'il a déjà été
	#               téléchargé, +false+ sinon.
	def telecharger(ecraser = false)
		if(!ecraser && self.telecharge?) then
			return self.chemin
		end
		unless(Dir.exist? "#{Bot.dir}/assets/cache") then
			Dir.mkdir("#{Bot.dir}/assets/cache")
		end
		begin
			File.open(self.chemin, "wb") { |fichier|
				open(@url, "rb") { |distant| fichier.write(distant.read) }
			}
		rescue OpenURI::HTTPError => e
			$stderr.puts(@url)
			e.full_message
			if(Bot.debug?) then
				exit(false)
			end
			return nil
		end
		return self.chemin
	end
	
	##
	# Teste si le fichier existe dans le répertoire <tt>assets/cache/</tt>.
	def telecharge?
		return File.exist? self.chemin
	end
	
	##
	# Retourne le fichier de l'image, après l'avoir téléchargé si besoin (File).
	def fichier
		return File.open(self.telecharger(false), "rb")
	end
	
end
