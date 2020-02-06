require_relative 'Bot.rb'
require_relative 'Expression.rb'
require_relative 'Erreurs.rb'

##
# Classe représentant un status.
#
# Un status est caractérisé par son texte.  
# Il peut être créé et envoyé.

class Status
	
	## Texte du status
	attr :texte, false
	
	## Création du status
	def Status.creer
		new()
	end
	
	## Initialisation aléatoire du status
	def initialize
		begin
			Bot.index['info'] = Info.elt_alea
			if Bot.index['info'].structure && Bot.index['info'].structure != "" then
				@texte = Bot.index['info'].structure.evaluer
			else
				Bot.index['sujet'] = Pers.elt_alea
				
				@texte = partie_info
				@texte = Accroche.retourner(nil, [@texte, "sujet"])
				if rand(2) == 1 then
					@texte += " " + partie_decla
				end
			end
		rescue IndexErreur => e
			puts "#{e.message} : réessai"
			retry
		end
	end
	
	## Renvoie le texte de l'info
	def to_s
		return self.texte
	end
	
	private
	
	##
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
	
	##
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
