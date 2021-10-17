require "rosace"
require_relative "action"

class Info < Rosace::Entity

	TYPES_ACTEUR = [
		:pers,
		:pays
	]

	CATEGORIES = [
		:internet,			# Personnalité liée à internet
			:videaste,		# Vidéaste sur internet
			:youtube,		# Youtubeur
			:twitch,		# Streamer
			:twitter,		# Twitto
		:politique,			# Personnalité politique
			:gauche,		# Gauche (officiellement)
			:droite,		# Droite (officiellement)
			:ext_gauche,	# Extrême-gauche (officiellement)
			:ext_droite,	# Extrême-droite (officiellement)
			:ecolo,			# Centre-gauche écologiste
			:centre,		# Centre (officiellement)
		:fiction,			# Personnage de fiction
		:culture,			# Personnalité culturelle
			:musique,		# Chanteur, musicien
			:jeu_video,		# Personnage ou personnalité du jeu vidéo
			:serie,			# Personnage ou comédien de série
			:cinema,		# Personnage ou comédien de cinéma
			:animation,		# Personnage de cartoon ou anime
			:bd,			# Personnage de bande dessinée, comics ou manga
			:humour,		# Humoristes
			:litterature,	# Personnage de littérature ou écrivain
		:anonyme,			# Monsieur-madame tout le monde
		:patronat,			# CEO, PDG, propriétaire d’entreprise
			:gafam,			# Patron de grande entreprise du numérique
		:sport,				# Sportif ou journaliste sportif
		:media,				# Personnalité des médias
			:edito,			# Éditorialiste
			:journalisme,	# Journaliste "neutre"
		:tv,				# Personnalité de divertissement télévisé
		:non_humain,		# Animal
	]

	ROLES = [:"", :sujet, :objet]

	TEMPORALITES = [:proche, :passe, :futur]

	self.file = "regles/info.csv"

	# @!attribute [r] emoji
	#  @return [String]
	# @!attribute [r] before
	#  @return [void]

	# @!attribute [r] acteurs
	#  @return [Array<Symbol>]
	mult_enum :acteurs, *TYPES_ACTEUR

	# @!attribute [r] categories
	#  @return [Array<Symbol>]
	mult_enum :categories, *CATEGORIES

	# @!attribute [r] temporalite
	#  @return [Symbol]
	mult_enum :temporalite, *TEMPORALITES

	# @!attribute [r] coupable
	#  @return [Symbol]
	enum :coupable, *ROLES

	# @!attribute [r] victime
	#  @return [Symbol]
	enum :victime, *ROLES

	# @!attribute [r] denonciateur
	#  @return [Symbol]
	enum :denonciateur, *ROLES

	# @!attribute [r] _action
	#  @return [Action, nil]
	# @!attribute [r] _action_list
	#  @return [Array<Action>]
	has_many :Action, :info, :_action

	# @!attribute [r] _decla
	#  @return [Decla, nil]
	# @!attribute [r] _decla_list
	#  @return [Array<Decla>]
	has_many :Decla, :ref_info, :_decla

	# @return [Acteur, nil]
	attr_accessor :objet

	# @return [void]
	def init
		@objet = nil
		@action = nil
	end

	# @return [String]
	def value
		before
		phrase = action.value(force_verbe: false) + if has_motif?
			phrase_motif = nil
			[:coupable, :victime, :denonciateur].each do |role|
				if send(role) == :objet && motif.send(role) == :sujet
					saved_context = context.clone
					begin
						phrase_motif = motif.accusation_qui(info: self)
					rescue Rosace::EvaluationException => e
						context.log(e)
						context.restore_state(saved_context)
					end
				end
			end
			phrase_motif ||= motif.accusation(info: self)
			" " + phrase_motif
		else
			""
		end + ". " + context.pick_entity(:StructDecla).value + " " +
		if rand(2) == 1
			"(#{context.pick_entity(:Media).value}) "
		else
			""
		end + hashtag
		context.pick_entity(:Accroche).value + " " + phrase
	end

	# @return [String]
	def hashtag
		s = super
		if s.empty?
			s
		else
			'#' + s
		end
	end

	# @return [Boolean]
	def has_motif?
		!coupable.empty? || !victime.empty? || !denonciateur.empty?
	end

	# @return [Action, nil]
	def motif
		if !coupable.empty? || !victime.empty? || !denonciateur.empty?
			@motif ||= context.pick_entity(
				:Action,
				coupable.empty? ? "" : "coupable",
				victime.empty? ? "" : "victime",
				denonciateur.empty? ? "" : "denonciateur"
			)
		else
			action
		end
	end

	# @return [Decla]
	def decla
		spec = rand(1 + _decla_list.reduce(0) { |w, d| w + d.weight }) > 0
		accu = rand(10) > 0
		@decla ||= spec && _decla || context.pick_entity(
			:Decla,
			!accu || coupable.empty? && action.coupable.empty? ?
				"" :
				"coupable",
			!accu || victime.empty? && action.victime.empty? ?
				"" :
				"victime",
			!accu || denonciateur.empty? && action.denonciateur.empty? ?
				"" :
				"denonciateur"
		)
	end

	# @return [Acteur, nil]
	def acteur
		context.pick_entity(:Pers)
	end

	# @return [Acteur, nil]
	def sujet
		# @type [Acteur, nil]
		@sujet ||= acteur
	end

	# @param acteur [Acteur]
	# @return [Acteur]
	def sujet=(acteur)
		unless @sujet.nil?
			raise Rosace::EvaluationException,
				"sujet déjà défini pour Info[#{id}]"
		end
		@sujet = acteur
	end

	# @return [Action, nil]
	def action
		@action ||= _action
	end

	# @param action [Action, nil]
	# @return [Acteur, nil]
	def get_victime(action: nil)
		action ||= self.action
		case victime
		when :sujet
			sujet
		when :objet
			objet ||= acteur
		else
			case action.victime
			when :sujet
				sujet
			when :objet
				objet ||= acteur
			else
				if !denonciateur.empty? || !action.denonciateur.empty?
					get_denonciateur(action: action)
				else
					nil
				end
			end
		end
	end

	# @param action [Action, nil]
	# @return [Acteur, nil]
	def get_coupable(action: nil)
		action ||= self.action
		case coupable
		when :sujet
			sujet
		when :objet
			objet ||= acteur
		else
			case action.coupable
			when :sujet
				sujet
			when :objet
				objet ||= acteur
			else
				nil
			end
		end
	end

	# @param action [Action]
	# @return [Acteur, nil]
	def get_denonciateur(action: nil)
		action ||= self.action
		case denonciateur
		when :sujet
			sujet
		when :objet
			objet ||= acteur
		else
			case action.denonciateur
			when :sujet
				sujet
			when :objet
				objet ||= acteur
			else
				if !victime.empty? || !action.victime.empty?
					get_victime(action: action)
				else
					nil
				end
			end
		end
	end
end