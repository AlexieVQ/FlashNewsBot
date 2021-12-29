require "rosace"

# Moment d'une information
class Moment < Rosace::Entity

    self.file = "regles/moment.csv"

    TEMPORALITES = [:proche, :passe, :futur, :present]

    # @!attribute [r] value
    #  @return [String] Valeur du moment
    # @!attribute [r] temporalite
    #  @return [Array<Symbol>] Temporalité du moment
    mult_enum :temporalite, *TEMPORALITES

    # Teste si le moment correspond à une des temporalités données.
    # @param temporalites [Array<String>] Temporalités à tester
    # @return [Boolean] Vrai si le moment correspond à une des temporalités
    #  données
    def pick?(*temporalites)
        temporalites.map { |str| str.strip.to_sym }.any? do |tmp|
            temporalite.any? { |stmp| stmp == tmp }
        end
    end

end