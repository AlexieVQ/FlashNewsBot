require "rosace"
require_relative "acteur"
require_relative "info"

class Entreprise < Rosace::Entity

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

    mult_enum :categories, *Info::CATEGORIES

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