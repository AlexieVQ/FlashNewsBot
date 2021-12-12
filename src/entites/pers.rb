require "rosace"
require_relative "acteur"
require_relative "../Bot"
require_relative "../refinements"
require_relative "categories"

class Pers < Rosace::Entity
	include Acteur
	self.file = "regles/pers.csv"

	# @!attribute [r] nom
	#  @return [String]
	# @!attribute [r] pascal_name
	#  @return [String]
	# @!attribute [r] cw
	#  @return [String]

	# @!attribute [r] genre
	#  @return [:M, :F]
	enum :genre, *Acteur::GENRES

	# @!attribute [r] nombre
	#  @return [:S, :P]
	enum :nombre, *Acteur::NOMBRES

	# @!attribute [r] categories
	#  @return [Array<Symbol>]
	mult_enum :categories, *CATEGORIES

	# @!attribute [r] origine
	#  @return [Lieu, nil]
	reference :origine, :Lieu, :optional

	# @!attribute [r] surnom
	#  @return [Surnom, nil]
	# @!attribute [r] surnom_list
	#  @return [Array<Surnom>]
	has_many :Surnom, :pers, :surnom

	# @return [void]
	def init
		# @type [Boolean]
		@nom_cite = false
	end

	# @return [String]
	def nom
		if !@nom_cite || surnom_list.empty?
			@nom_cite = true
			super
		else
			surnom.value
		end
	end

	# @return [Integer] Poids du personnage dans les choix aléatoires
	def weight
		poids = super
		if Bot.compte
			if Bot.bdd.pers_recemment_poste(self, Bot.compte) > 0
				return 1
			end
			poids += Bot.bdd.interactions_pers(self, Bot.compte)
			# @type [Integer]
			taille = plain_value(:nom).length
			poids += (taille - Bot.compte.tendances.
					reduce(1000) do |distance, tendance|
				[self.distance(tendance), distance].min
			end) * 10
		end
		# @type [Info, nil]
		info = context.variable(:$info)
		if info
			cat_sujet = info.instance_variable_get(:@sujet).
					respond_to?(:categories) ?
					info.sujet.categories :
					[]
			((info.categories | cat_sujet) & categories).each { poids *= 20 }
			if info.lieux.any? { |lieu| lieu.parent?(origine) }
				poids *= 20
			end
		end
		poids
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

end