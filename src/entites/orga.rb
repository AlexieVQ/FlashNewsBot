require "rosace"
require_relative "acteur"
require_relative "categories"
require_relative "../refinements"

# Une organisation politique, syndicale ou associative.
class Orga < Rosace::Entity

    using Refinements

    include Acteur

    self.file = "regles/orga.csv"

    # @!attribute [r] nom
    #  @return [String] Nom de l'organisation
    # @!attribute [r] sigle
    #  @return [String] Sigle de l'organisation
    # @!attribute [r] emoji
    #  @return [String] Emoji représentant l'organisation

    # @!attribute [r] genre
    #  @return [:M, :F] Genre du nom de l'organisation
    enum :genre, *Acteur::GENRES

    # @!attribute [r] nombre
    #  @return [:S, :P] Nombre du nom de l'organisation
    enum :nombre, *Acteur::NOMBRES

    # @!attribute [r] type
    #  @return [Symbol] Type d'organisation
    enum :type, :parti, :syndicat, :association

    mult_enum :categories, *CATEGORIES

    # @!attribute [r] origine
    #  @return [Lieu, nil] Origine de l'organisation
    reference :origine, :Lieu, :optional

    # Teste si l'organisation est de type attendu.
    # @param types [Array<String>] types attendus
    # @return [Boolean] +true+ si l'organisation est de type attendu
    def pick?(*types)
        types.empty? || types.any? { |type| type.strip.to_sym == self.type }
    end

	# @return [Integer] Poids de l'organisation dans les choix aléatoires
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

	# Retourne la distance avec la chaîne donnée
	# @param chaine [String] chaîne à comparer
	# @return [Integer] Distance entre les deux chaînes
	def distance(chaine)
		[
            plain_value(:nom).levenshtein(chaine),
            plain_value(:sigle).levenshtein(chaine)
        ].min
	end

    # @return [Integer] Nombre supérieur à 1
    def qte
        1000
    end

    # @return [Integer] Troisième personne
    def personne
        3
    end

    # @see #sigle
    def pascal_case
        sigle
    end

	# Adjectif des militants de l'organisation.
	# @param genre [#to_sym] Genre de l'adjectif
	# @param nombre [#to_sym] Nombre de l'adjectif
	# @return [String] Adjectif des militants de l'organisation
	def adj(genre = :M, nombre = :S)
		self.genre_adj = genre.to_sym
		self.nombre_adj = nombre.to_sym
		super()
	end

	# Définit les formes différentes d'{#adj} selon le genre et le nombre
	# @param ms [String] Masculin singulier
	# @param fs [String] Féminin singulier
	# @param mp [String] Masculin pluriel
	# @param fp [String] Féminin pluriel
	# @return [String] Forme correspondant au genre et au nombre courent
	def defgn(ms, fs, mp, fp)
		if genre_adj == :M
			if nombre_adj == :S
				ms
			else
				mp
			end
		else
			if nombre_adj == :S
				fs
			else
				fp
			end
		end
	end

    # Similaire à `.defgn(iste,iste,istes,istes)`.
    # @see #defgn
    def iste
        defgn("iste", "iste", "istes", "istes")
    end

    # @return [Array<Symbol>] Catégories de l'association
    def categories
        super + ([:parti, :syndicat].include?(type) ? [:politique] : [])
    end

	private

	# @return [:M, :F] Genre courent de l'adjectif
	attr_accessor :genre_adj

	# @return [:S, :P] Nombre courent de l'adjectif
	attr_accessor :nombre_adj

end