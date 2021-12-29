require 'rosace'
require_relative 'generateur'

# Un status à envoyer au réseau social. Il se construit aléatoirement à la
# création.

class Status
	
	#############
	# ATTRIBUTS #
	#############
	
	# @return [String] Texte du status
	attr_reader :texte
	
	# @return [Rosace::Context] Contexte du status
	attr_reader :context

	# @return [Info] Information principale du status
	attr_reader :info
	
	# @return [Array<Pers>] Array de Pers présentes dans le status
	attr_reader :pers
	
	# @return [Array<Images>] Images du status
	attr_reader :images
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée un nouveau status de manière aléatoire.
	#
	# L'index est d'abord réinitialisé (voir Bot::index_reset). Une information
	# est stockée dans son entrée +info+. Si l'information a une structure
	# personnalisée (voir Info#structure), celle-ci est évaluée. Sinon un
	# personnage sujet de l'information est stocké dans +sujet+. L'action de
	# l'information (voir Info#action) est évaluée, avec possible ajout d'une
	# DateInfo et d'un Lieu. Ensuite une Accroche est ajouté en début de status,
	# puis une deuxième partie où le sujet réagit à l'information est
	# aléatoirement ajoutée, ou non. Cette partie incorpore Info#decla,
	# Pers#declas ou une déclaration universelle.
	def initialize
		begin
			@context = GENERATEUR.new_evaluation_context
			@texte = context.pick_entity(:Main).value
			@pers = []
			@images = []
			@info = context.variable(:$info)
		rescue Rosace::EvaluationException => e
			puts "#{e.message} : réessai" if(Bot.debug?)
			retry
		end
	end
	
	############
	# MÉTHODES #
	############
	
	##
	# Représente le status sous la forme <tt>[<em>Avertissements</em>]<em>Texte
	# du status</em> [<em>Description de de l'image</em> <em>URL de
	# l'image</em>]</tt>.
	def to_s
		chaine = self.cw? ? "[#{self.cw_string}] #{@texte}" : "#{@texte}"
		return @images.reduce(chaine) do |chaine, image|
			chaine + " " + image.to_s
		end
	end
	
	##
	# Retourne les avertissements de contenu pour le status (Array de String,
	# vide si aucun avertissement).
	def cw
		[]
	end
	
	##
	# Retourne un avertissement de contenu pour le status (String, vide ou
	# +nil+, concaténation des résultats de Status#cw).
	def cw_string
		return self.cw.join(", ")
	end
	
	##
	# Teste si status a un avertissement de contenu (voir Status#cw).
	def cw?
		return self.cw.length > 0
	end
end
