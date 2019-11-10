##
# Ajout à la classe Array de méthodes pour obtenir un élément du tableau de
# manière aléatoire.
#
# Si les éléments ont un attribut poids, cela influencera sur le choix de
# l'élément.

class Array
	
	## Retourne un élément du tableau aléatoirement
	def elt_alea
		somme_poids = 0
		self.each do |elt|
			somme_poids += elt.poids == nil ? 1 : elt.poids
		end
		
		i = 0
		nb_rand = rand(somme_poids)
		while nb_rand > 0 do
			nb_rand -= self[i].poids == nil ? 1 : self[i].poids
			i += 1
		end
		
		return self[i]
	end
	
end
