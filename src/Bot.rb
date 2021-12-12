require 'daemons'
require_relative 'Status.rb'
require_relative 'Bdd.rb'
require_relative 'CompteTwitter.rb'

##
# Classe contenant le programme principal du bot.

class Bot
	
	#######################
	# VARIABLES DE CLASSE #
	#######################
	
	# @@bdd				=> Base de données (Bdd)
	# @@dir				=> Chemin du dossier contenant FlashNewsBot.rb (String)
	# @@index			=> Index (Hash)
	# @@compte			=> Compte utilisé
	# @@debug			=> Mode débuggage (booléen, utilisé en mode offline)
	# @@sujet_surnomme	=> Si le sujet a été surnommé dans le status, ou non
	#					   (booléen)
	# @@taux			=> Taux de mentions traitées (Integer, de 0 à 100
	#					   inclus)
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	##
	# Initialise les attributs de la classe, sans lancer l'exécution du bot.
	#
	# Méthode automatiquement appelée par Bot::exec.
	#
	# Paramètres :
	# [+offline+]       Indique si le bot doit être exécuté hors-ligne (+true+,
	#                   status générés écrits sur la sortie standard) ou en
	#                   ligne (+false+, status envoyés au compte Twitter donné)
	# [+username+]      Nom d'utilisateur du compte Twitter (String, ignoré si
	#                   +offline+ est à +true+)
	# [+intervalle+]    Intervalle, en minutes, entre chaque status (Integer ou
	#                   Float)
	# [+debug+]         Utilisation du mode débuggage (booléen, utilisé en mode
	#                   offline)
	# [+password+]      Mot de passe de la base de données (String)
	# [+taux+]          Taux de mentions traitées (Integer, de 0 à 100 inclus)
	def Bot.init(offline, username, intervalle, debug, password, taux)
		@@bdd = nil
		@@intervalle = intervalle
		@@dir = Dir.pwd
		@@compte = nil
		@@debug = offline || debug
		@@taux = taux
		
		unless(offline) then
			@@bdd = Bdd.new(password) # Doit être connectée pour enregistrer le 
									  # compte
			@@compte = CompteTwitter.connecter(username)
		end
	end
	
	##
	# Lance l'exécution du bot.
	#
	# Le bot est d'abord initialisé, puis il est démonisé. Si +offline+ est à
	# +false+, le bot se connecte sur le compte d'+username+ donné avant d'être
	# démonisé. S'il est à +true+, le programme n'est pas démonisé et les
	# résultats s'affichent sur la sortie standard.
	#
	# Paramètres :
	# [+offline+]       Indique si le bot doit être exécuté hors-ligne (+true+,
	#                   status générés écrits sur la sortie standard) ou en
	#                   ligne (+false+, status envoyés au compte Twitter donné)
	# [+username+]      Nom d'utilisateur du compte Twitter (String, ignoré si
	#                   +offline+ est à +true+)
	# [+intervalle+]    Intervalle, en minutes, entre chaque status (Integer ou
	#                   Float)
	# [+debug+]         Utilisation du mode débuggage (booléen, utilisé en mode
	#                   offline)
	# [+password+]      Mot de passe de la base de données (String)
	# [+taux+]          Taux de mentions traitées (Integer, de 0 à 100 inclus)
	def Bot.exec(offline, username, intervalle, debug, password, taux)
		self.init(offline, username, intervalle, debug, password, taux)
		unless(offline) then
			Daemons.daemonize({backtrace: true,
							   app_name: username + "." + @@compte.domaine,
							   log_output: true})
			@@bdd = Bdd.new(password) # Doit être reconnectée après la
									  # démonisation
		end
		
		mini_inter = 5 * 60 # Intervalle de vérification des commentaires

		loop {
			restant = intervalle * 60 # Temps d'attente restant en secondes
			marque = Time.now.to_i # secondes
			tentative = 0
			begin
			
				status = Status.new

				puts "[#{Time.now}] #{status} " +
					 "(#{status.info.categories.join(", ")})" if(self.debug?)
				unless(offline) then
					if(status.texte.length <= @@compte.limite) then
						@@compte.envoyer(status)
					end
				end
		
			rescue => e
				if(e.respond_to? :full_message) then
					$stderr.puts(e.full_message)
				else
					$stderr.puts(e)
				end
				if(!self.debug? && tentative < 5) then
					tentative += 1
					retry
				end
				exit(false) if(self.debug?)
			end
				
			begin # Mise à jour des status
				@@compte.update_statuses if(@@compte)
			rescue => e
				if(e.respond_to? :full_message) then
					$stderr.puts(e.full_message)
				else
					$stderr.puts(e)
				end
				exit(false) if(self.debug?)
			end
			sleep(60 * @@intervalle)
		}
	end
	
	##
	# Chemin du répertoire où se trouve l'exécutable <tt>FlashNewsBot.rb</tt>
	# (String).
	def Bot.dir
		return @@dir
	end
	
	##
	# Base de données (Bdd, +nil+ si hors-ligne)
	def Bot.bdd
		return @@bdd
	end
	
	##
	# Compte utilisé par le bot (+nil+ si hors-ligne)
	def Bot.compte
		return nil # @@compte
	end
	
	##
	# Teste si le bot est hors-ligne (+true+), ou poste des status sur un compte
	# (+false+).
	def Bot.hors_ligne?
		return @@compte == nil
	end
	
	##
	# Teste si le bot est en mode débuggage.
	def Bot.debug?
		return @@compte.nil? || @@debug
	end
	
	##
	# Intervalle (minutes) entre chaque status (Integer ou Float)
	def Bot.intervalle
		return @@intervalle
	end
	
	private_class_method :new
end
