require_relative 'Array.rb'
require_relative 'Bdd.rb'

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
	def retourner(attribut, parametres)
		case @commande
		when TypeCommande::RAND then
			return rand(parametres)
		when TypeCommande::MAJ then
			return parametres[0].capitalize
		when TypeCommande::CAP then
			return parametres[0].upcase
		when TypeCommande::GENRE then
			return genre(parametres[0], parametres[1], parametres[2])
		when TypeCommande::GSE then
			return genre("sujet", "", "e")
		when TypeCommande::ACCROCHE then
			return $bdd.accroches.elt_alea
		when TypeCommande::PERS then
			return $bdd.pers(genre: parametres[0]).elt_alea
		when TypeCommande::DATE then
			return $bdd.dates.elt_alea
		when TypeCommande::LIEU then
			return $bdd.lieux.elt_alea
		when TypeCommande::LOCALITE then
			if ["ville", "pays", "region"].include?(parametres[0]) then
				return $bdd.localites(type: parametres).elt_alea
			else
				return $bdd.localites(nom_colle: parametres[0]).elt_alea
			end
		when TypeCommande::PARTI then
			return $bdd.partis(parametres).elt_alea
		when TypeCommande::MEDIA then
			return $bdd.medias.elt_alea
		when TypeCommande::CIRCO then
			return $bdd.circos.elt_alea
		when TypeCommande::DECLA then
			return $bdd.declas.elt_alea
		else
			return nil
		end
	end
	
	private
	
	##
	# Prend un tableau de chaînes de caractères en paramètres et retourne une
	# des chaînes aléatoirement.
	def rand(chaines)
		return chaines.elt_alea
	end
	
	##
	# Prend le nom d'un personnage dans l'index, une chaîne au masculin et une
	# au féminin et renvoie celle correspondant au genre du personnage.
	def genre(nom_pers, chaine_m, chaine_f)
		if $index[nom_pers].genre == 'M' then
			return chaine_m
		elsif $index[nom_pers].genre == 'F' then
			return chaine_f
		else
			return nil
		end
	end
	
end