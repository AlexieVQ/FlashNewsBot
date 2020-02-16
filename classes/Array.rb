require_relative 'String.rb'

##
# Ajout à la classe Array d'une méthode pour obtenir un élément du tableau de
# manière aléatoire.

class Array
	
	##
	# Retourne un élément du tableau aléatoirement
	#
	# Si les éléments ont un attribut +poids+, le choix est pondéré par ce
	# poids. Sinon le poids est défini à +1+ par défaut.
	#
	# Paramètres :
	# [+ajout+] Éléments à ajouter dans la recherche (Array, vide par défaut)
	#
	# Lève une *RuntimeError* si le tableau est vide.
	def elt_alea(ajout = [])
		somme_poids = 0
		tab = self + ajout
		if(tab.length == 0) then
			raise "Tableau vide"
		end
		tab.each do |elt|
			somme_poids += elt.respond_to?(:poids) ? elt.poids : 1
		end
		
		nb_rand = rand(somme_poids)
		tab.each do |elt|
			nb_rand -= elt.respond_to?(:poids) ? elt.poids : 1
			if(nb_rand <= 0) then
				return elt
			end
		end
	end
	
end
