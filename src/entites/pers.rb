require "rosace"
require_relative "acteur"
require_relative "../Bot"
require_relative "../refinements"
require_relative "categories"

class Pers < Rosace::Entity

	using Refinements

	include Acteur

	self.file = "regles/pers.csv"

	# @!attribute [r] cw
	#  @return [String]

	enum :genre, *Acteur::GENRES, :C

	# @!attribute [r] nombre
	#  @return [:S, :P]
	enum :nombre, *Acteur::NOMBRES

	# @!attribute [r] categories
	#  @return [Array<Symbol>]
	mult_enum :categories, *CATEGORIES

	# @!attribute [r] origine
	#  @return [Lieu, nil]
	reference :origine, :Lieu, :optional

	has_many :Surnom, :pers, :_surnom

	# @return [void]
	def init
		# @type [Boolean]
		@nom_cite = false
		# @type [Boolean]
		@commun = false
	end

	# @return [String] Nom ou surnom du personnage, si son nom a déjà été donné.
	def nom
		commun
		if @forcer_nom || !@nom_cite
			@nom_cite = true
			super()
		else
			self.surnom
		end
	end

	# @return [String] Surnom du personnage
	def surnom
		_surnom_list.empty? ?
				"l#{ n("’", "es ") }intéressé#{ es }" :
				_surnom.value
	end

	# @return [:M, :F] Genre grammatical du personnage
	def genre
		commun
		if super == :C
			qte.times do |i|
				return :M if send(:"acteur#{i + 1}").genre == :M
			end
			:F
		else
			super
		end
	end

	def vocatif
		@forcer_nom = true
		out = super
		@forcer_nom = false
		out
	end

	# @return [String] Nom en PascalCase du personnage (pour les hashtags)
	def pascal_case
		commun
		super
	end

	# @return [Integer] Poids du personnage dans les choix aléatoires
	def weight
		poids = super
		# @type [Info, nil]
		info = context.variable(:$info)
		if info
            if info.contient?(self)
                return 1
            end
			cat_sujet = info.instance_variable_get(:@sujet).
					respond_to?(:categories) ?
					info.sujet.categories :
					[]
			((info.categories | cat_sujet) & categories).each { poids *= 20 }
			if info.lieux.any? { |lieu| lieu.parent?(origine) }
				poids *= 20
			end
		end
		if Bot.compte
			# if Bot.bdd.pers_recemment_poste(self, Bot.compte) > 0
			# 	return 1
			# end
			# poids += Bot.bdd.interactions_pers(self, Bot.compte)
			# @type [Integer]
			taille = plain_value(:nom).length
			poids += (taille - Bot.compte.tendances.
					reduce(1000) do |distance, tendance|
				[self.distance(tendance), distance].min
			end) * 10
		end
		poids
	end

	# Teste si ce personnage peut-être choisi.
	# @param nombre ["S", "P", nil] Nombre du personnage
	# @return [Boolean] Vrai si le personnage peut-être choisi
	def pick?(nombre = nil)
		if nombre == "S"
			self.nombre == :S
		elsif nombre == "P"
			self.nombre == :P
		else
			true
		end
	end

	# Retourne la distance avec la chaîne donnée
	# @param chaine [String] chaîne à comparer
	# @return [Integer] Distance entre les deux chaînes
	def distance(chaine)
		plain_value(:nom).levenshtein(chaine)
	end

	# @return [1, 2, 3]
	def personne
		3
	end

	# @return [Integer]
	def qte
		super.to_i
	end

	# @return [Lieu, nil]
	def pays
		if origine
			origine.pays
		else
			nil
		end
	end

	# @return [String]
	def emoji_origine
		if origine
			origine.emoji
		else
			""
		end
	end

	# Exécute les macros définis dans l'attribut +commun+ avant d'accéder aux
	# informations du personnage.
	# @return [void]
	def commun
		unless @commun
			super
			@commun = true
		end
		self
	end

end