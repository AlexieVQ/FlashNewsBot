require 'net/http'
require 'oauth'
require 'json'
require_relative 'Compte.rb'
require_relative 'Bot.rb'
require_relative 'Bdd.rb'

##
# Compte Twitter.

class CompteTwitter < Compte
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	##
	# Crée un nouvel accès à l'API pour le compte d'<tt>username</tt> donné. Si
	# le compte n'existe pas dans la base de données, les clés de l'API sont
	# demandées dans la console. Puis il est demandé d'ouvrir le lien donné sur
	# un navigateur, de s'authentifier sur Twitter et de copier dans la console
	# le code obtenu. Si le compte existe déjà dans la base de données, seule
	# l'authentification est demandée.
	#
	# Paramètres :
	# [+username+]  Nom d'utilisateur (String)
	def CompteTwitter.connecter(username)
		if(compte = Bot.bdd.compte_twitter(username)) then
			return new(compte[:id], username, compte[:api_key],
			           compte[:api_secret])
		else
			print "Clé d'API : "
			api_key = gets.chomp
			print "Clé secrète d'API : "
			api_secret = gets.chomp
			id = new_compte_twitter(username, api_key, api_secret)
			return new(id, username, api_key, api_secret)
		end
		
	end
	
	#############
	# ATTRIBUTS #
	#############
	
	##
	# Identifiant du compte dans la base de données (Integer)
	attr_reader :id
	
	#######################
	# VARIABLES DE CLASSE #
	#######################
	
	# @username		=> Nom d'utilisateur du compte Twitter (String)
	# @api_key		=> Clé de l'API Twitter (String)
	# @api_secret	=> Clé secrète de l'API Twitter (String)
	# @access_token	=> Token d'accès à l'API (OAuth::AccessToken)
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée un nouvel accès au compte Twitter d'<tt>username</tt> donné et
	# s'authentifie auprès de Twitter.
	#
	# *Attention* : la classe ne peut être instanciée hors de la classe
	# CompteTwitter. Utiliser CompteTwitter::connecter.
	#
	# Paramètres :
	# [+id+]            Identifiant du compte dans la base de données (Integer)
	# [+username+]      Nom d'utilisateur (String)
	# [+api_key+]       Clé d’API Twitter (String)
	# [+api_secret+]    Clé secrète d'API Twitter (String)
	def initialize(id, username, api_key, api_secret)
		@id = id
		@username = username
		@api_key = api_key
		@api_secret = api_secret
		consumer = OAuth::Consumer.new(@api_key,
		                               @api_secret,
		                               {:site => "https://api.twitter.com",
		                               :scheme => :header})
		request_token = consumer.get_request_token(:oauth_callback => 'oob')
		oauth_token = request_token.token
		oauth_token_secret = request_token.secret
		url = request_token.authorize_url(:oauth_callback => 'oob')
		
		# Demande à l'utilisateur d'ouvrir l'URL, d'autoriser l'application et
		# d'écrire le code obtenu dans le terminal
		
		puts "Ouvrez " + url + " dans votre navigateur et autorisez " +
			"l'application."
		print "Code obtenu : "
		oauth_verifier = gets.chomp
		hash = {
			oauth_token: oauth_token,
			oauth_token_secret: oauth_token_secret
		}
		request_token = OAuth::RequestToken.from_hash(consumer, hash)
		@access_token = request_token.get_access_token(
			{:oauth_verifier => oauth_verifier,
		     :oauth_token => oauth_token,
		     :oauth_token_secret => oauth_token_secret}
		)
	end
	
	############
	# MÉTHODES #
	############
	
	##
	# Envoie le status sur le compte Twitter et le stocke dans la base de
	# données (Retourne son id, Integer).
	#
	# Paramètres :
	# [+status+]    Status
	def envoyer(status)
		reponse = @access_token.post(
			"https://api.twitter.com/1.1/statuses/update.json",
			{:status => status.texte})
		
# 		if(reponse == Net::HTTPSuccess) then
			tweet = JSON.parse(reponse.body)
			Bot.bdd.insert_status(tweet["id"].to_i, self, tweet["created_at"],
			                      status.info, status.pers)
			return tweet["id"].to_i
# 		else
# 			reponse.value
# 		end
	end
	
	##
	# Limite de caractères d'un status (Integer)
	def limite
		return 280
	end
	
end
