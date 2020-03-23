require_relative '../Bot.rb'
require_relative 'Element.rb'
require_relative 'Localite.rb'
require_relative '../String.rb'

##
# Element placé au début d'un status ("BREAKING NEWS", "ALERTE INFO", "C'est
# officiel" ...).
#
# Les accroches sont définies dans la table +accroches.csv+.

class Accroche < Element
	
	########################
	# CONSTANTES DE CLASSE #
	########################
	
	## <tt>"accroches.csv"</tt> (String)
	FICHIER = "accroches.csv"
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	# Crée une Accroche à partir d'une ligne d'un fichier CSV.
	def Accroche.importer(ligne)
		new(ligne['id'].to_i, ligne['accroche'], ligne['poids'].to_i)
	end
	
	##
	# Si <tt>parametres[0]</tt> contient un String, ajoute une accroche complète
	# au début de cette chaîne, comprenant emoji, mot d'accroche ou hashtag, et 
	# nom du personnage, si son mot-clef l'identifiant dans l'index est présent
	# dans <tt>parametres[1]</tt>.
	#
	# Sinon, retourne un mot d'accroche ("BREAKING NEWS", "FLASH INFO" ...)
	# aléatoirement.
	def Accroche.retourner(attribut = nil, parametres = [])
		if(parametres[0]) then
			accroche = rand(2) == 1 ? "⚡" : "🔴"
			
			# Ajout d'emojis régionaux
			accroche += Localite.dans_index.reject { |localite|
				localite == Localite.FRANCE &&
					!Localite.dans_index(false).member?(Localite.FRANCE)
			}.map { |localite| localite.emoji }.join
			
			# Si l'info a un hashtag, ajoute le hashtag puis le nom du
			# personnage dans parametres[1], et arrête la construction de la
			# chaîne.
			if(parametres[1] && Bot.index['info'].hashtag) then
				accroche += " " + Bot.index['info'].hashtag + " — " +
						Bot.index[parametres[1]].nom.majuscule
			else
				# Ajout du nom du personnage sous forme de hashtag ou non, puis
				# de son surnom.
				if(parametres[1] && rand(4) == 1) then
					if(rand(2) == 1) then
						accroche += " #" + Bot.index[parametres[1]].nom_colle
					else
						accroche += " " + Bot.index[parametres[1]].nom.majuscule
					end
					accroche += " : "
					if(parametres[1] == 'sujet') then
						if(Bot.sujet_surnomme?) then
							accroche += Bot.index['sujet'].pronom
						else
							accroche += Bot.index['sujet'].surnom
							Bot.sujet_surnomme = true
						end
					else
						accroche += Bot.index[parametres[1]].surnom
					end
				# Ajout d'un mot d'arroche, puis du nom du personnage, si donné.
				else
					accroche += " " + elt_alea.accroche
					accroche =~ /:/ ? accroche += " " : accroche += " — "
					if(parametres[1]) then
						accroche += Bot.index[parametres[1]].nom.majuscule
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
	
	private_class_method :new
	private_class_method :importer
	
	########################
	# VARIABLES D'INSTANCE #
	########################
	
	# @accroche		=> Formulation de l'accroche (String)
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée une Accroche d'identifiant, de valeur et de poids donnés.
	#
	# *Attention* : une Accroche ne peut être instanciée hors de sa classe.
	#
	# Paramètres :
	# [+id+]        Identifiant de l'accroche (Integer, voir Element#id)
	# [+accroche+]  String contenant l'accroche, telle que définie dans la table
	# [+poids+]     Poids défini dans la table (Integer, voir
	#               Element#poids_statique)
	def initialize(id, accroche, poids)
		super(id, poids)
		@accroche = accroche
	end
	
	#######################
	# MÉTHODES D'INSTANCE #
	#######################
	
	##
	# Retourne l'accroche (String) juste après l'avoir évaluée (voir
	# String#evaluer).
	def accroche
		return @accroche.evaluer
	end
	
	alias :to_s :accroche
	
end
