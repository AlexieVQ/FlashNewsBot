require "rosace"
require_relative "action"

class Info < Rosace::Entity

	TYPES_ACTEUR = [
		:pers,
		:pays,
		:entreprise
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

	TEMPORALITES = [:proche, :passe, :futur, :present]

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

	enum :coupable, *ROLES
	enum :victime, *ROLES
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
		phrase = action.value + if has_motif?
			" pour " + motif.value(
				temps: :infinitif_passe,
				coupable: coupable,
				victime: victime
			)
		else
			""
		end + ". " # + context.pick_entity(:StructDecla).value + " " +
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
		!coupable.nil? || !victime.nil? || !denonciateur.nil?
	end

	# @return [Action, nil]
	def motif
		if has_motif?
			@motif ||= context.pick_entity(
				:Action,
				coupable.nil? ? "" : "coupable",
				victime.nil? ? "" : "victime",
				denonciateur.nil? ? "" : "denonciateur"
			)
		else
			nil
		end
	end

	# @return [Decla]
	def decla
		spec = rand(1 + _decla_list.reduce(0) { |w, d| w + d.weight }) > 0
		accu = rand(10) > 0
		@decla ||= spec && _decla || context.pick_entity(
			:Decla,
			!accu || coupable.nil? ? "" : "coupable",
			!accu || victime.nil? ? "" : "victime",
			!accu || denonciateur.nil? ? "" : "denonciateur"
		)
	end

	# @return [Acteur, nil]
	def acteur
		a = []
		if acteurs.include?(:pers)
			a << context.pick_entity(:Pers)
		end
		if acteurs.include?(:pays)
			a << context.pick_entity(:Lieu, "pays")
		end
		if acteurs.include?(:entreprise)
			a << context.pick_entity(:Entreprise)
		end
		a[rand(a.length)]
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

	# @return [Acteur, nil] Coupable de l'information
	def coupable
		case super
		when :sujet
			sujet
		when :objet
			objet
		else
			nil
		end
	end

	# @return [Acteur, nil] Victime de l'information
	def victime
		case super
		when :sujet
			sujet
		when :objet
			objet
		else
			denonciateur
		end
	end

	# @return [Acteur, nil] Dénonciateur de l'information
	def denonciateur
		case super
		when :sujet
			sujet
		when :objet
			objet
		else
			nil
		end
	end

end