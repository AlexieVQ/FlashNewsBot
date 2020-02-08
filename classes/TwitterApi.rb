require 'net/http'
require 'oauth'
require 'json'
require_relative 'Api.rb'
require_relative 'Bot.rb'
require_relative 'Bdd.rb'

##
# API Twitter.

class TwitterApi < Api
	
	######################
	# MÉTHODES DE CLASSE #
	######################
	
	##
	# Voir TwitterApi::new
	def TwitterApi.connecter(username)
		new(username)
	end
	
	#######################
	# VARIABLES DE CLASSE #
	#######################
	
	# @access_token	=> Token d'accès à l'API (OAuth::AccessToken)
	# @id_bdd		=> ID de l'app dans la base (Integer)
	
	################
	# CONSTRUCTEUR #
	################
	
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
	def initialize(username)
		super(username)
		@limite = 280
	end
	
	############
	# MÉTHODES #
	############
	
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
	def envoyer(status)
		reponse = @access_token.post(
			"https://api.twitter.com/1.1/statuses/update.json",
			{:status => status.texte})
		
		unless(reponse == Net::HTTPSuccess) then
			reponse.value
		end
	end
	
	private
	
	# Authentifie l'application auprès de Twitter pour l'username donné.
	def auth(username)
		session = Hash.new
		unless(@id_bdd = Bot.bdd.app("twitter.com", username, session)) then
			print "Clé d'API : "
			session[:api_key] = gets.chomp
			print "Clé secrète d'API : "
			session[:api_secret] = gets.chomp
		end
		consumer = OAuth::Consumer.new(session[:api_key],
		                               session[:api_secret],
		                               {:site => "https://api.twitter.com",
		                               :scheme => :header})
		request_token = consumer.get_request_token(:oauth_callback => 'oob')
		session[:oauth_token] = request_token.token
		session[:oauth_token_secret] = request_token.secret
		url = request_token.authorize_url(:oauth_callback => 'oob')
		
		# Demande à l'utilisateur d'ouvrir l'URL, d'autoriser l'application et
		# d'écrire le code obtenu dans le terminal
		
		puts "Ouvrez " + url + " dans votre navigateur et autorisez " +
			"l'application."
		print "Code obtenu : "
		session[:oauth_verifier] = gets.chomp
		hash = {
			oauth_token: session[:oauth_token],
			oauth_token_secret: session[:oauth_token_secret]
		}
		request_token = OAuth::RequestToken.from_hash(consumer, hash)
		@access_token = request_token.get_access_token(
			{:oauth_verifier => session[:oauth_verifier],
		     :oauth_token => session[:oauth_token],
		     :oauth_token_secret => session[:oauth_token_secret]}
		)
		unless(@id_bdd) then
			reponse = @access_token.get(
				"https://api.twitter.com/1.1/account/settings.json")
			username = JSON.parse(reponse.body)["screen_name"]
			@id_bdd = Bot.bdd.enregistrer_app(ApiType::TWITTER,
			                               "twitter.com",
			                               username,
			                               session[:api_key],
			                               session[:api_secret])
		end
	end
	
end
