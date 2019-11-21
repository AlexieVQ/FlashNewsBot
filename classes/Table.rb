##
# Classe représentant une table stockée dans un fichier CSV.

class Table
	
	## Données
	attr :donnees, false
	
	##
	# Pour charger une table, il faut le chemin du fichier .csv, et
	# optionnellement le séparateur de ses données et un booléen qui indique si
	# la première ligne représente le titre des colonnes.
	def Table.charger(chemin, separateur = ";", header = true)
		new(nil, chemin, separateur, header)
	end
	
	## Initialisation
	def initalize(donnees, chemin = nil, separateur = nil, header = nil)
		if donnees then
			@donnees = donnees
		else
			@donnees = CSV.read(chemin,
			                    {:col_sep => separateur, :headers = header})
		end
	end
	
	##
	# Effectue une sélection sur la table et retourne une nouvelle table.
	def selectionner(&bloc_test)
		nouv_donnees = @donnees.inject(Array.new) do |tab, ligne|
			if bloc_test.call(ligne) then
				tab << ligne
			end
		end
		return Table.new(nouv_donnees)
	end
	
end
