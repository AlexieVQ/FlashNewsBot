##
# Ajout à la classe Array de méthodes pour obtenir un élément du tableau de
# manière aléatoire.
#
# Si les éléments ont un attribut poids, cela influencera sur le choix de
# l'élément.

class Array
	
	##
	# Retourne un élément du tableau ou d'un tableau passé en paramètre
	# aléatoirement.
	def elt_alea(ajout = [])
		somme_poids = 0
		tab = self | ajout
		tab.each do | elt |
			somme_poids += elt.poids == nil ? 1 : elt.poids
		end
		
		nb_rand = rand(somme_poids)
		tab.each do | elt |
			nb_rand -= elt.poids == nil ? 1 : elt.poids
			if nb_rand <= 0 then
				return elt
			end
		end
	end
	
end
