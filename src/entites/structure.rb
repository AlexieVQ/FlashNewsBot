require "rosace"

# Structure personnalisée d'une {Info}.
class Structure < Rosace::Entity

    self.file = "regles/structure.csv"

    # @!attribute [r] value
    #  @return [String] Valeur de la structure

    # @!attribute [r] info
    #  @return [Info] Information liée à la structure
    reference :info, :Info, :required

end