require 'daemons'
require_relative 'Status.rb'
require_relative 'Bdd.rb'
require_relative 'CompteTwitter.rb'
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
	def Bot.init(offline, username, intervalle, debug)
		@@bdd = nil
		@@intervalle = intervalle
		@@dir = Dir.pwd
		@@compte = nil
		@@debug = offline || debug
		self.index_reset
		
		unless(offline) then
			@@bdd = Bdd.new # Doit être connectée pour enregistrer le compte
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
	def Bot.exec(offline, username, intervalle, debug)
		self.init(offline, username, intervalle, debug)
		unless(offline) then
			Daemons.daemonize({backtrace: true,
							   app_name: username + "." + @@compte.domaine,
							   log_output: true})
			@@bdd = Bdd.new # Doit être reconnectée après la démonisation
		end

		loop {
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
				e.full_message
				if(!self.debug? && tentative < 5) then
					tentative += 1
					retry
				end
				exit(false) if(self.debug?)
			end
				
			begin
				@@compte.update_statuses if(@@compte)
			rescue => e
				e.full_message
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
		return @@compte
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
	
	##
	# Teste si le sujet a été surnommé dans le status, ou non (booléen).
	def Bot.sujet_surnomme?
		return @@sujet_surnomme
	end
	
	##
	# Définit si le sujet a été surnommé dans le status, ou non (booléen).
	def Bot.sujet_surnomme=(bool)
		return @@sujet_surnomme = bool
	end
	
	##
	# Index (Hash) faisant correspondre des identifiants utilisés dans les
	# expressions à leurs valeurs associées.
	#
	# Les éléments présent dans l'index sont des Expression, des instances ou
	# des classes héritant de Element. Ils doivent tous implémenter une méthode
	# +retourner+ prenant en paramètres +attribut+ (String) et +pamaretres+
	# (Array de String). Voir la documentation de String#evaluer pour plus de
	# détails.
	def Bot.index
		return @@index
	end
	
	##
	# (Ré)initialise l'index (voir Bot::index) en définissant les commandes
	# +rand+, +maj+, +cap+, +genre+, +gse+, +h+ (voir Expression) et les classes
	# d'éléments +accroche+ (voir Accroche), +pers+ (voir Pers), +date+ (voir
	# DateInfo), +lieu+ (voir Lieu), +localite+ (voir Localite), +parti+ (voir
	# Parti), +media+ (voir Media), +circo+ (voir Circo) et +decla+ (voir
	# Decla).
	def Bot.index_reset
		@@index = Hash.new
		
		@@index['rand'] = Expression.new(:rand)
		@@index['maj'] = Expression.new(:maj)
		@@index['cap'] = Expression.new(:cap)
		@@index['genre'] = Expression.new(:genre)
		@@index['gse'] = Expression.new(:gse)
		@@index['h'] = Expression.new(:h)
		@@index['randn'] = Expression.new(:randn)
		@@index['accroche'] = Accroche
		@@index['pers'] = Pers
		@@index['date'] = DateInfo
		@@index['lieu'] = Lieu
		@@index['localite'] = Localite
		@@index['parti'] = Parti
		@@index['media'] = Media
		@@index['circo'] = Circo
		@@index['decla'] = Decla
		
		return @@index
	end
	
	private_class_method :new
end
