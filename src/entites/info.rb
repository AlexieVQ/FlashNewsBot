require "rosace"
require_relative "../Bot"
require_relative "../refinements"
require_relative "../inspectable"
require_relative "action"
require_relative "entreprise"
require_relative "lieu"
require_relative "categories"

class Info < Rosace::Entity

	using Refinements

	include Inspectable

	TYPES_ACTEUR = [
		:pers,
		:pays,
		:region,		# Concerne aussi les départements et états
		:entreprise,
		:parti,
		:syndicat,
		:association,
		:media
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

	# Retourne tous les lieux présents dans l'info.
	# @param multi_niveaux [Boolean] Vrai s'il faut retourner également les
	#  lieux qui ne sont pas directement dans l'info
	# @return [Array<Lieu>] Lieux présents dans l'info
	def lieux(multi_niveaux: true)
		lieux = []
		lieux << lieu if respond_to?(:lieu) && lieu
		[@sujet, @objet].each do |acteur|
			if multi_niveaux && acteur.respond_to?(:origine)
				lieux << acteur.origine if acteur.origine
			elsif acteur.is_a?(Lieu)
				lieux << acteur
			end
		end
		lieux += @action.lieux if multi_niveaux && @action
		lieux += @motif.lieux if multi_niveaux && @motif
		lieux.uniq
	end

	# @return [String] Retourne les emojis des pays présents dans l'info.
	def emojis_pays
		lieux.map { |lieu| lieu.emoji }.uniq.join("")
	end

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
				sujet_explicite: true, temps: temps) + ".\n\n" +
				context.pick_entity(:StructDecla).value.majuscule + ".\n\n" +
				(rand(2) == 1 ?
						"(#{context.pick_entity(:Media).value}) " :
						"") +
				hashtag
		context.pick_entity(:Accroche).value + " " + phrase
	end

	# Calcule le poids de l'information lors de choix aléatoires.
	# @return [Integer] Poids de l'information
	def weight
		# @type [Integer]
		poids = super
		if Bot.compte
			# if Bot.bdd.info_recemment_poste(self, Bot.compte) > 0
			# 	return 1
			# end
			# poids += Bot.bdd.interactions_info(self, Bot.compte)
			# @type [Integer]
			taille = _action.plain_value(:nominale).length if _action
			poids += ([taille - Bot.compte.tendances.
					reduce(1000) do |distance, tendance|
				[self.distance(tendance), distance].min
			end, 0].max) * 10
		end
		poids
	end

	# Retourne la distance avec la chaîne donnée
	# @param chaine [String] chaîne à comparer
	# @return [Integer] Distance entre les deux chaînes
	def distance(chaine)
		if _action
			_action.plain_value(:nominale).levenshtein(chaine)
		else
			chaine.length
		end
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

	# @return [Array<:coupable, :victime>] Rôles définis pour
	#  cette information.
	def roles
		roles = []
		roles << :coupable if coupable
		roles << :victime if victime
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
		when :region
			context.pick_entity(:Lieu, "region", "departement", "etat")
		when :entreprise
			context.pick_entity(:Entreprise)
		when :parti
			context.pick_entity(:Orga, "parti")
		when :syndicat
			context.pick_entity(:Orga, "syndicat")
		when :association
			context.pick_entity(:Orga, "association")
		when :media
			context.pick_entity(:Media)
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
			@victime
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