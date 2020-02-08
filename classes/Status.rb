require_relative 'Bot.rb'
require_relative 'Expression.rb'
require_relative 'Erreurs.rb'

##
# Un status à envoyer au réseau social. Il se construit aléatoirement à la
# création.

class Status
	
	#############
	# ATTRIBUTS #
	#############
	
	##
	# Texte du status (String)
	attr_reader :texte
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée un nouveau status de manière aléatoire.
	#
	# L'index est d'abord réinitialisé (voir Bot::index_reset). 
	def initialize
		begin
			Bot.index_reset
			
			# Choix de l'information principale du status
			Bot.index['info'] = Info.elt_alea
			
			# Cas où l'information a une structure personnalisée : on évalue la
			# structure
			if(Bot.index['info'].structure && Bot.index['info'].structure != "")
			then
				@texte = Bot.index['info'].structure.evaluer
			else
				# Choix du personnage sujet de l'information
				Bot.index['sujet'] = Pers.elt_alea
				
				# Génération de la partie information
				@texte = partie_info
				# Ajout de l'accroche
				@texte = Accroche.retourner(nil, [@texte, "sujet"])
				# Ajout de la deuxième partie du status, où le sujet prend la
				# parole
				if(rand(2) == 1) then
					@texte += " " + partie_decla
				end
			end
		rescue IndexErreur => e
			puts "#{e.message} : réessai"
			retry
		end
	end
	
	alias :to_s :texte
	
	private
	
	# Génère la partie principale contenant l'action de l'information et
	# éventuellement sa circonstance, son lieu...  
	# Le sujet n'est pas nommé.
	def partie_info
		chaine = Bot.index['info'].action
		
		if rand(2) == 1 then
			chaine += " " + Bot.index['date'].retourner.date
		end
		
		if rand(2) == 1 then
			chaine += " " + Bot.index['lieu'].retourner.lieu
		end
		
		if rand(2) == 1 then
			chaine += " " + Bot.index['info'].circo
		end
		
		return chaine + "."
	end
	
	# Génère la partie contenant la déclaration du sujet.
	def partie_decla
		chaine = Bot.index['sujet'].surnom.majuscule
		
		chaine += " " + case rand(3)
		when 0 then "a déclaré"
		when 1 then "aurait déclaré"
		when 2 then "aurait dit"
		end
		
		if rand(2) == 1 then
			chaine += " " + Bot.index['date'].retourner.date
		end
		
		if rand(2) == 1 then
			chaine += " " + Bot.index['media'].retourner.nom("à")
		end
		
		if rand(2) == 1 then
			chaine += " " + Bot.index['circo'].retourner.circo
		end
		
		chaine += " “" + Bot.index['info'].decla + "”"
		return chaine + "."
	end
	
end
