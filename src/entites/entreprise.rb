require "rosace"
require_relative "acteur"
require_relative "categories"
require_relative "../refinements"

class Entreprise < Rosace::Entity

    using Refinements

    include Acteur

    self.file = "regles/entreprise.csv"

    # @!attribute [r] nom
    #  @return [String]
    # @!attribute [r] emoji
    #  @return [String]

    # @see #nom
    def value
        nom
    end

    # @!attribute [r] genre
    #  @return [:M, :F]
    enum :genre, *Acteur::GENRES

    # @!attribute [r] nombre
    #  @return [:S, :P]
    enum :nombre, *Acteur::NOMBRES

    # @!attribute [r] origine
    #  @return [Lieu, nil]
    reference :origine, :Lieu, :optional

    # @!attribute [r] patron
    #  @return [Pers, nil]
    reference :patron, :Pers, :optional

    mult_enum :categories, *CATEGORIES

	# @return [Integer] Poids de l'entreprise dans les choix aléatoires
	def weight
		# @type [Info, nil]
		info = context.variable(:$info)
		poids = super
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
		if
			plain_value(:value).levenshtein(chaine)
		else
			chaine.length
		end
	end

    # @return [Array<Symbol>]
    def categories
        super + [:patronat]
    end

    # @return [Lieu, nil]
    def pays
        origine ? origine.pays : nil
    end

    # @return [3]
    def personne
        3
    end

    # @return [Integer]
    def qte
        1000
    end

end