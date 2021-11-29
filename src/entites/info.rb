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
	enum :temporalite, *TEMPORALITES

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

	# @return [Action, nil] Motif d'accusation.
	attr_accessor :motif

	# @return [void]
	def init
		@objet = nil
		@action = nil
	end

	# @return [String]
	def value
		before
		temps = case :temporalite
		when :proche
			:passe
		when :present
			:simple
		when :passe
			:passe
		when :futur
			:simple
		else
			:passe
		end
		phrase = action.value(sujet: sujet, objet: objet,
				sujet_explicite: true, temps: temps) + ". " + context.
				pick_entity(:StructDecla).value + " " + if rand(2) == 1
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

	# @return [Array<:coupable, :victime, :denonciateur>] Rôles définis pour
	#  cette information.
	def roles
		roles = []
		roles << :coupable if coupable
		roles << :victime if victime
		roles << :denonciateur if denonciateur
		roles
	end

	# @return [Decla]
	def decla
		spec = rand(1 + _decla_list.reduce(0) { |w, d| w + d.weight }) > 0
		accu = rand(10) > 0
		@decla ||= spec && _decla || context.pick_entity(:Decla,
				*(accu ? roles.map { |role| role.to_s } : []))
	end

	# @return [Acteur, nil]
	def acteur
		case type_acteur
		when :pers
			context.pick_entity(:Pers)
		when :pays
			context.pick_entity(:Lieu, "pays")
		when :entreprise
			context.pick_entity(:Entreprise)
		else
			nil
		end
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
			@coupable
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
			if @victime
				@victime
			else
				denonciateur
			end
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

	# Définit le coupable, s'il n'est pas déjà défini.
	# @param coupable [Acteur] Coupable à définir
	# @return [Acteur] Coupable défini
	# @raise Coupable déjà défini
	def coupable=(coupable)
		if self.coupable
			raise "Info[#{id}]: coupable déjà défini"
		end
		@coupable = coupable
	end

	# Définit la victime, si elle n'est pas déjà définie.
	# @param victime [Acteur] Victime à définir
	# @return [Acteur] Victime définie
	# @raise Victime déjà définie
	def victime=(victime)
		if self.victime
			raise "Info[#{id}]: victime déjà définie"
		end
		@victime = victime
	end

	private

	# @return [Symbol] Type d'acteur de l'information
	def type_acteur
		@type_acteur ||= acteurs[rand(acteurs.size)]
	end

end