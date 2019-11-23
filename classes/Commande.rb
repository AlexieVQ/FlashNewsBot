require_relative 'String.rb'
require_relative 'Array.rb'
require_relative 'Erreurs.rb'
require_relative 'elements/Accroche.rb'
require_relative 'elements/Pers.rb'
require_relative 'elements/DateInfo.rb'
require_relative 'elements/Lieu.rb'
require_relative 'elements/Localite.rb'
require_relative 'elements/Parti.rb'
require_relative 'elements/Media.rb'
require_relative 'elements/Circo.rb'
require_relative 'elements/Decla.rb'

##
# Liste des identifiants des commandes disponibles.

module TypeCommande
	## rand(a,b,c)
	RAND = 1
	## maj(chaine)
	MAJ = 2
	## cap(chaine)
	CAP = 3
	## genre(perso,le,la)
	GENRE = 4
	## gse <=> genre(sujet,,e)
	GSE = 5
	## {h} : affiche aléatoirement un # ou non
	H = 6
	## Création des accroches
	ACCROCHE = 10
	## Création des personnages
	PERS = 11
	## Création des dates
	DATE = 12
	## Création des lieux
	LIEU = 13
	## Création d'une localité
	LOCALITE = 14
	## Création d'une organisation politique
	PARTI = 15
	## Création d'un média
	MEDIA = 16
	## Création d'une circonstance
	CIRCO = 17
	## Création d'une déclaration
	DECLA = 18
end

##
# Classe représentant les commandes présentes dans l'index, utilisées dans les
# éléments de la base de données.
#
# Exemples de commandes : {rand(a,b,c)}, {maj(chaine)}, {cap(chaine)},
# {genre(perso,le,la)}.

class Commande
	
	## TypeCommande
	attr :commande, false
	
	private_class_method :new
	
	##
	# Initialisation de la commande.
	def Commande.commande(commande)
		new(commande)
	end
	
	## Méthode privée
	def initialize(commande)
		@commande = commande
	end
	
	##
	# Retourne le résultat de la commande pour l'attribut et les paramètres
	# donnés.
	def retourner(attribut = nil, parametres = nil)
		case @commande
		when TypeCommande::RAND then
			return random(parametres)
		when TypeCommande::MAJ then
			return parametres[0].majuscule
		when TypeCommande::CAP then
			return parametres[0].upcase
		when TypeCommande::GENRE then
			return genre(parametres[0], parametres[1], parametres[2])
		when TypeCommande::GSE then
			return genre("sujet", "", "e")
		when TypeCommande::H then
			return random(["", "#"])
		when TypeCommande::ACCROCHE then
			element = Accroche.elt_alea
		when TypeCommande::PERS then
			if attribut && attribut != "" || parametres[0] == nil then
				element = Pers.elt_alea
			elsif parametres[0] then
				element = Pers.genre(parametres[0]).elt_alea
			end
		when TypeCommande::DATE then
			element = DateInfo.elt_alea
		when TypeCommande::LIEU then
			element = Lieu.elt_alea
		when TypeCommande::LOCALITE then
			if ["ville", "pays", "region"].include?(parametres[0]) then
				element = Localite.types(parametres).elt_alea
			elsif parametres && parametres.length != 0 then
				element = Localite.nom_colle(parametres[0]).elt_alea
			else
				element = Localite.elt_alea
			end
		when TypeCommande::PARTI then
			if ["parti", "syndicat", "association"].include?(parametres[0]) then
				element = Parti.types(parametres).elt_alea
			else
				element = Parti.elt_alea
			end
		when TypeCommande::MEDIA then
			element = Media.elt_alea
		when TypeCommande::CIRCO then
			element = Circo.elt_alea
		when TypeCommande::DECLA then
			element = Decla.elt_alea
		end
		
		if attribut && attribut != "" then
			return element.retourner(attribut, parametres)
		else
			return element
		end
	end
	
	## Retourne une chaîne de caractères sans attribut ni paramètres
	def to_s
		return self.retourner(nil, nil).to_s
	end
	
	private
	
	##
	# Prend un tableau de chaînes de caractères en paramètres et retourne une
	# des chaînes aléatoirement.
	def random(chaines)
		return chaines.elt_alea
	end
	
	##
	# Prend le nom d'un personnage dans l'index, une chaîne au masculin et une
	# au féminin et renvoie celle correspondant au genre du personnage.
	def genre(nom_pers, chaine_m, chaine_f)
		unless $index[nom_pers] then
			raise IndexErreur, "#{nom_pers} absent de l'index"
		end
		if $index[nom_pers].genre == 'M' then
			return chaine_m
		elsif $index[nom_pers].genre == 'F' then
			return chaine_f
		else
			return nil
		end
	end
	
end
