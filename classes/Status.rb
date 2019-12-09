require_relative 'Commande.rb'
require_relative 'Erreurs.rb'
require_relative 'elements/Info.rb'
require_relative 'elements/Pers.rb'
require_relative 'elements/Accroche.rb'
require_relative 'elements/DateInfo.rb'
require_relative 'elements/Lieu.rb'
require_relative 'elements/Localite.rb'
require_relative 'elements/Parti.rb'
require_relative 'elements/Media.rb'
require_relative 'elements/Circo.rb'
require_relative 'elements/Decla.rb'

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
			$index = Hash.new

			$index['rand'] = Commande.commande(TypeCommande::RAND)
			$index['maj'] = Commande.commande(TypeCommande::MAJ)
			$index['cap'] = Commande.commande(TypeCommande::CAP)
			$index['genre'] = Commande.commande(TypeCommande::GENRE)
			$index['gse'] = Commande.commande(TypeCommande::GSE)
			$index['h'] = Commande.commande(TypeCommande::H)
			$index['accroche'] = Accroche
			$index['pers'] = Pers
			$index['date'] = DateInfo
			$index['lieu'] = Lieu
			$index['localite'] = Localite
			$index['parti'] = Parti
			$index['media'] = Media
			$index['circo'] = Circo
			$index['decla'] = Decla
			
			$index['info'] = Info.elt_alea
			if $index['info'].structure && $index['info'].structure != "" then
				@texte = $index['info'].structure.evaluer
			else
				$index['sujet'] = Pers.elt_alea
				
				@texte = partie_info
				@texte = accroche + " " + @texte
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
		chaine = $index['info'].action
		
		if rand(2) == 1 then
			chaine += " " + $index['date'].retourner.date
		end
		
		if rand(2) == 1 then
			chaine += " " + $index['lieu'].retourner.lieu
		end
		
		if rand(2) == 1 then
			chaine += " " + $index['info'].circo
		end
		
		return chaine + "."
	end
	
	##
	# Génère la partie contenant la déclaration du sujet.
	def partie_decla
		chaine = $index['sujet'].surnom.majuscule
		
		chaine += " " + case rand(3)
		when 0 then "a déclaré"
		when 1 then "aurait déclaré"
		when 2 then "aurait dit"
		end
		
		if rand(2) == 1 then
			chaine += " " + $index['date'].retourner.date
		end
		
		if rand(2) == 1 then
			chaine += " " + $index['media'].retourner.nom("à")
		end
		
		if rand(2) == 1 then
			chaine += " " + $index['circo'].retourner.circo
		end
		
		chaine += " “" + $index['info'].decla + "”"
		return chaine + "."
	end
	
	##
	# Génère l'accroche du status, qui contient le nom du sujet.
	def accroche
		chaine = rand(2) == 1 ? "⚡" : "🔴"
		
		if $index['loc_info'] && $index['loc_info'].emoji != "" then
			chaine += $index['loc_info'].emoji
		elsif $index['sujet'].localite && $index['sujet'].localite.nom_colle !=
				"France" then
			chaine += $index['sujet'].localite.emoji
		end
		
		if $index['info'].hashtag then
			chaine += " " + $index['info'].hashtag + " : " + $index['sujet'].nom
		else
			if rand(4) == 1 then
				if rand(2) == 1 then
					chaine += " #" + $index['sujet'].nom_colle
				else
					chaine += " " + $index['sujet'].nom.majuscule
				end
				chaine += " : " + $index['sujet'].surnom
			else
				chaine += " " + $index['accroche'].retourner.accroche
				chaine =~ /:/ ? chaine += " " : chaine += " - "
				chaine += $index['sujet'].nom
			end
		end
		
		return chaine
	end
	
end
