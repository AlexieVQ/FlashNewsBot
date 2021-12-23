require "rosace"
require_relative "acteur"
require_relative "categories"
require_relative "../refinements"

class Media < Rosace::Entity

	using Refinements

	include Acteur

	# Id du média FlashNewsBot
	FNB = 27

	self.file = "regles/media.csv"

	# @!attribute [r] value
	#  @return [String]
	# @!attribute [r] nom
	#  @return [String]
	# @!attribute [r] pascal_case
	#  @return [String]

	# @!attribute [r] genre
	#  @return [:M, :F]
	enum :genre, *Acteur::GENRES

	enum :nombre, *Acteur::NOMBRES

	# @!attribute [r] types
	#  @return [Array<Symbol>]
	mult_enum :types, :papier, :tv, :radio, :internet

	mult_enum :categories, *CATEGORIES

	# @!attribute [r] origine
	#  @return [Lieu] Origine du média
	reference :origine, :Lieu, :required

	# @see #nom
	def value
		nom
	end

	# @return [Integer] Poids du média dans les choix aléatoires
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
			if info.lieux.any? { |lieu| origine.parent?(lieu) }
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

	# Retourne la distance avec la chaîne donnée
	# @param chaine [String] chaîne à comparer
	# @return [Integer] Distance entre les deux chaînes
	def distance(chaine)
        plain_value(:nom).levenshtein(chaine)
	end

	# @return [Array<String>] Catégories du média
	def categories
		super + [:media, :journalisme] + (types.include?(:tv) ? [:tv] : [])
	end

	# @return [1, 3] Personne du média (3e sauf pour FlashNewsBot à la 1e)
	def personne
		id == FNB ? 1 : 3
	end

	# @return [:S, :P] Nombre grammatical du media
	def nombre
		id == FNB ? :P : super
	end

	# @return [Integer] Entier supérieur à 1
	def qte
		50
	end

end