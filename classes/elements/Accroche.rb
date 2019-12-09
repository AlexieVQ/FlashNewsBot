require_relative 'Element.rb'
require_relative '../String.rb'

##
# Classe représentant l'accroche d'une information, héritant de la classe
# Element.
#
# Une arroche est caractérisée par sa formulation.

class Accroche < Element
	
	# @accroche		=> Formulation de l'accroche
	
	## Nom du fichier CSV correspondant
	def Accroche.nom_fichier
		return "accroches.csv"
	end
	
	##
	# Crée une accroche à partir d'une ligne d'un fichier CSV.
	def Accroche.importer(ligne)
		new(ligne['id'].to_i, ligne['accroche'], ligne['poids'].to_i)
	end
	
	##
	# Retourne une expression d'accroche aléatoire, ou ajoute une accroche à la
	# chaîne présente dans parametres[0] en tenant compte du personnage dans
	# parametres[1].
	def Accroche.retourner(attribut = nil, parametres = [])
		if parametres[0] then
			accroche = rand(2) == 1 ? "⚡" : "🔴"
			
			if $index['loc_info'] && $index['loc_info'].emoji != "" then
				accroche += $index['loc_info'].emoji
			elsif parametres[1] && $index[parametres[1]].localite &&
					$index[parametres[1]].localite.nom_colle != "France" then
				accroche += $index[parametres[1]].localite.emoji
			end
			
			if parametres[1] && $index['info'].hashtag then
				accroche += " " + $index['info'].hashtag + " : " +
						$index[parametres[1]].nom
			else
				if parametres[1] && rand(4) == 1 then
					if rand(2) == 1 then
						accroche += " #" + $index[parametres[1]].nom_colle
					else
						accroche += " " + $index[parametres[1]].nom.majuscule
					end
					accroche += " : " + $index[parametres[1]].surnom
				else
					accroche += " " + elt_alea.accroche
					accroche =~ /:/ ? accroche += " " : accroche += " - "
					if parametres[1] then
						accroche += $index[parametres[1]].nom.majuscule
					else
						return accroche + " " + parametres[0].majuscule
					end
				end
			end
			return accroche + " " + parametres[0]
		else
			return super(attribut, parametres)
		end
	end
	
	## Méthode privée
	def initialize(id, accroche, poids)
		super(id, poids)
		@accroche = accroche
	end
	
	## Donne l'accroche (une chaîne de caractères) juste après l'avoir évaluée.
	def accroche
		return @accroche.evaluer
	end
	
	## Conversion en chaîne de caractères.
	def to_s
		return self.accroche
	end
	
end
