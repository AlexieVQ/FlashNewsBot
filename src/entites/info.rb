require "rosace"
require_relative "../Bot"
require_relative "../refinements"
require_relative "../inspectable"
require_relative "action"
require_relative "entreprise"
require_relative "lieu"
require_relative "categories"
require_relative "moment"

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
		:media
	]

	ROLES = [:"", :sujet, :objet]

	self.file = "regles/info.csv"

	# @!attribute [r] acteurs
	#  @return [Array<Symbol>]
	mult_enum :acteurs, *TYPES_ACTEUR

	# @!attribute [r] categories
	#  @return [Array<Symbol>]
	mult_enum :categories, *CATEGORIES

	# @!attribute [r] temporalite
	#  @return [Symbol]
	enum :temporalite, *Moment::TEMPORALITES

	# @!attribute [r] coupable
	#  @return [:sujet, :objet, :""] coupable de l'info
	enum :coupable, *ROLES

	# @!attribute [r] victime
	#  @return [:sujet, :objet, :""] victime de l'info
	enum :victime, *ROLES

	# @!attribute [r] _action
	#  @return [Action, nil]
	# @!attribute [r] _action_list
	#  @return [Array<Action>]
	has_many :Action, :info, :_action, :required

	# @!attribute [r] _decla
	#  @return [Decla, nil]
	# @!attribute [r] _decla_list
	#  @return [Array<Decla>]
	has_many :Decla, :ref_info, :_decla

	# @!attribute [r] structure
	#  @return [Structure, nil] Structure personnalisée de l'info
	# @!attribute [r] structure_list
	#  @return [Structure, nil] Structures personnalisées de l'info
	has_many :Structure, :info, :structure

	# @return [Acteur, nil] Objet de l'information
	attr_reader :objet

	# Retourne tous les lieux présents dans l'info.
	# @param multi_niveaux [Boolean] Vrai s'il faut retourner également les
	#  lieux qui ne sont pas directement dans l'info
	# @return [Array<Lieu>] Lieux présents dans l'info
	def lieux(multi_niveaux: true)
		lieux = []
		lieux << lieu if respond_to?(:lieu) && lieu
		[@sujet, @objet].each do |acteur|
			if multi_niveaux
				lieux << acteur.origine if acteur.respond_to?(:origine) &&
						acteur.origine
				lieux << acteur.lieu if acteur.respond_to?(:lieu) && acteur.lieu
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
		@commun = false
	end

	# @return [String]
	def value
		commun
		if structure_list.empty?
			temps = case temporalite
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
			part_value = action.value(sujet: sujet, objet: objet,
					sujet_explicite: true, temps: temps,
					verbe_obligatoire: true).majuscule
			part_motif = action.part_motif
			part_decla = begin
				context.pick_entity(:StructDecla).value.majuscule
			rescue Rosace::EvaluationException => e
				$stderr.puts "Pas de decla pour Info[#{id}]" if Bot.debug?
				nil
			end
			phrase = part_value +
					#" " +context.pick_entity(:Moment, temporalite.to_s).value +
					(part_motif.empty? ? "" : " " + part_motif) + ".\n\n" +
					(part_decla ? part_decla + ".\n\n" : "") +
					"(#{context.pick_entity(:Media).nom.majuscule}) " +
					hashtag
			context.pick_entity(:Accroche).value + " " + phrase
		else
			structure
		end
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

	# @return [String] Émojis de l'info et des acteurs si applicable
	def emoji
		s = super
		if s.empty?
			[@sujet, @objet].map do |acteur|
				(!acteur.is_a?(Lieu) && acteur.respond_to?(:emoji)) ?
						acteur.emoji :
						""
			end.uniq.join("")
		else
			s
		end
	end

	# @return [String]
	def hashtag
		commun
		s = super
		if s.empty?
			s
		else
			/\A#/ =~ s ? s : '#' + s
		end
	end

	# @return [Array<:coupable, :victime>] Rôles définis pour
	#  cette information.
	def roles
		roles = []
		roles << :coupable unless coupable.empty?
		roles << :victime unless victime.empty?
		roles
	end

	# @return [Decla]
	def decla
		spec = rand(1 + _decla_list.reduce(0) { |w, d| w + d.weight }) > 0
		gen = roles.empty? ? rand(100) == 0 : rand(10) > 5
		@decla ||= spec && _decla || gen && context.pick_entity(:Decla,
				*(gen ? roles.map { |role| role.to_s } : [])) || nil
	end

	# Retourne un acteur correspondant à un type d'{#acteurs}.
	# @return [Acteur, nil] Acteur correspondant au type donné, ou aucun acteur
	#  si cette information ne spécifie aucun type
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
		when :media
			context.pick_entity(:Media)
		else
			nil
		end
	end

	# @return [Acteur, nil] Sujet de l'information
	def sujet
		# @type [Acteur, nil]
		@sujet ||= acteur
	end

	# Lève une exception si le {Pers} d'id donné est sujet.
	# @param id [#to_i] Id du personnage
	# @return [""]
	# @raise Rosace::EvaluationException Le {Pers} d'id donné est sujet
	def not_sujet(id)
		if sujet.respond_to?(:id) && sujet.id == id.to_i
			raise Rosace::EvaluationException, "Pers[#{id}] est déjà sujet"
		end
		""
	end

	# Lève une exception si le {Pers} d'id donné est objet.
	# @param id [#to_i] Id du personnage
	# @return [""]
	# @raise Rosace::EvaluationException Le {Pers} d'id donné est objet
	def not_objet(id)
		if objet.respond_to?(:id) && objet.id == id.to_i
			raise Rosace::EvaluationException, "Pers[#{id}] est déjà objet"
		end
		""
	end

	def sujet=(acteur)
		unless @sujet.nil?
			raise Rosace::EvaluationException,
				"sujet déjà défini pour Info[#{id}]"
		end
		@sujet = acteur
	end

	def objet=(acteur)
		unless @objet.nil?
			raise Rosace::EvaluationException,
				"objet déjà défini pour Info[#{id}]"
		end
		@objet = acteur
	end

	# @return [Action] Action de l'information.
	def action
		@action ||= _action
	end

	# @return [Action, nil] Motif d'accusation correspondant à l'information.
	def motif
		@motif ||= context.pick_entity(:Action, *roles.map do |role|
			role.id2name
		end)
	end

	def motif=(action)
		unless @motif.nil?
			raise Rosace::EvaluationException,
				"motif déjà défini pour Info[#{id}]"
		end
		@motif = action
	end

	# Exécute les macros définis dans l'attribut +commun+ avant d'accéder aux
	# informations de l'info.
	# @return [void]
	def commun
		unless @commun
			super
			@commun = true
		end
		self
	end

	def inspect
		"#<Info[#{id}]#{ instance_variables.reduce("") do |str, variable|
			unless [:@attributes, :@context].include?(variable)
				str + " #{variable}=#{instance_variable_get(variable).inspect}"
			else
				str
			end
		end }>"
	end

	private

	# @return [Symbol] Type d'acteur de l'information
	def type_acteur
		@type_acteur ||= acteurs[rand(acteurs.size)]
	end

end