require_relative 'String.rb'
require_relative 'Array.rb'
require_relative 'Erreurs.rb'

##
# Classe représentant les commandes présentes dans l'index, utilisées dans les
# éléments de la base de données.
#
# Exemples de commandes : {rand(a,b,c)}, {maj(chaine)}, {cap(chaine)},
# {genre(perso,le,la)}.

class Expression
	
	def Expression.rand(attribut, parametres)
		return parametres.elt_alea
	end
	
	def Expression.maj(attribut, parametres)
		return parametres[0].majuscule
	end
	
	def Expression.cap(attribut, parametres)
		return parametres[0].upcase
	end
	
	def Expression.genre(attribut, parametres)
		nom_pers = parametres[0]
		chaine_m = parametres[1]
		chaine_f = parametres[2]
		unless($index[nom_pers]) then
			raise IndexErreur, "#{nom_pers} absent de l'index"
		end
		if($index[nom_pers].genre == 'M') then
			return chaine_m
		elsif($index[nom_pers].genre == 'F') then
			return chaine_f
		else
			return nil
		end
	end
	
	def Expression.gse(attribut, parametres)
		return Expression.genre(attribut, ["sujet", "", "e"])
	end
	
	def Expression.h(attribut, parametres)
		return Expression.rand(attribut, ["", "#"])
	end
	
	def Expression.randn(attribut, parametres)
		return (parametres[0].to_i..parametres[1].to_i).to_a.sample.to_s
	end
	
	## Méthode privée
	def initialize(commande)
		@commande = commande
	end
	
	##
	# Retourne le résultat de la commande pour l'attribut et les paramètres
	# donnés.
	def retourner(attribut = nil, parametres = nil)
		return @commande.call(attribut, parametres)
	end
	
	## Retourne une chaîne de caractères sans attribut ni paramètres
	def to_s
		return self.retourner(nil, nil).to_s
	end
	
end
