# Module qui permet de chercher parmi les variables d'instance d'un objet.
module Inspectable

    # Teste si l'objet donné est contenu par cet objet.
    # @param objet Objet à rechercher
    # @param operateur [Symbol] Opérateur d'identité à utiliser
    # @return [Boolean] Vrai si l'objet donné est ou contient l'objet recherché
    def contient?(objet, operateur: :==)
        if send(operateur, objet)
            true
        else
            instance_variables.any? do |variable|
                obj = instance_variable_get(variable)
                if obj.is_a?(Inspectable)
                    obj.contient?(objet)
                else
                    obj.send(operateur, objet)
                end
            end
        end
    end

end