require_relative 'String.rb'

##
# Ajout au module Enumerable d'une méthode pour obtenir un élément de
# l'énumération aléatoirement.

module Enumerable
	
	##
	# Retourne un élément de l'énumération aléatoirement.
	#
	# Si les éléments ont une méthode +poids+, le choix est pondéré par ce
	# poids. Sinon le poids est défini à +1+ par défaut.
	#
	# Paramètres :
	# [+ajout+] Éléments à ajouter dans la recherche (Array, vide par défaut)
	#
	# Lève une *RuntimeError* si l'énumération et +ajout+ sont vides.
	def elt_alea(ajout = [])
		tab = self.to_a + ajout
		if(tab.length == 0) then
			raise "Énumération vide"
		end
		somme = self.somme_poids(ajout)
		
		nb_rand = rand(somme)
		tab.each { |elt|
			nb_rand -= elt.respond_to?(:poids) ? elt.poids : 1
			if(nb_rand <= 0) then
				return elt
			end
		}
	end
	
	##
	# Retourne la somme des poids des éléments de l'énumération.
	#
	# Si les éléments n'ont pas de méthode +poids+, celui-ci est défini à +1+.
	#
	# Paramètres :
	# [+ajout+] Éléments à ajouter éphémèrement à l'énumération (Array, vide par
	#           défaut)
	def somme_poids(ajout = [])
		return (self.to_a + ajout).reduce(0) { |somme, elt|
			somme + (elt.respond_to?(:poids) ? elt.poids : 1)
		}
	end
	
	##
	# Retourne la somme des poids statiques des éléments de l'énumération.
	#
	# Si les éléments n'ont pas de méthode +poids_statique+, utilise la méthode
	# +poids+, et défini le poids à +1+ en dernier recourt.
	#
	# Paramètres :
	# [+ajout+] Éléments à ajouter éphémèrement à l'énumération (Array, vide par
	#           défaut)
	def somme_poids_statiques(ajout = [])
		return (self.to_a + ajout).reduce(0) { |somme, elt|
			somme + (elt.respond_to?(:poids_statique) ? elt.poids_statique :
			         (elt.respond_to?(:poids) ? elt.poids : 1))
		}
	end
	
end
