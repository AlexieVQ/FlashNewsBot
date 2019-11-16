require 'net/http'
require 'oauth'
require 'json'
require_relative 'Bdd.rb'

##
# Type d'API.

module ApiType
	## Twitter
	TWITTER = 1
end

##
# Classe représentant l’API du réseau social utilisé (Twitter pour l'instant,
# Mastodon à l’avenir), et les méthodes d'accès à cette API.

class Api
	
	## Type du réseau social, voir ApiType
	attr :type, false
	## Nom de domaine du réseau social (ex : twitter.com, mastodon.social)
	attr :domane, false
	## Limite de caractères du réseau social
	attr :limite, false
	
	# @url_base		=> URL de base de l'API (ex : https://api.twitter.com)
	# @session		=> Stockage des tokens
	# @access_token	=> Token d'accès à l'API
	# @id_bdd		=> ID de l'app dans la base
	
	private_class_method :new
	
	##
	# Connexion à l'API.
	#
	# Paramètres :
	# - username : Nom d'utilisateur
	# - type : ApiType::TWITTER
	# - domaine : "twitter.com"
	
	def Api.connecter(username,
	                  type = ApiType::TWITTER,
	                  domaine = "twitter.com")
		new(username, type, domaine)
	end
	
	## Méthode privée
	def initialize(username, type, domaine)
		@session = Hash.new
		@type = type
		case type
		when ApiType::TWITTER then
			@instance = "twitter.com"
			@url_base = "https://api.twitter.com"
			@limite = 280
			auth_twitter(username)
		end
	end
	
	##
	# Envoie un statut sur le réseau social.
	
	def envoyer(texte)
		case @type
		when ApiType::TWITTER then
			reponse = @access_token.post(
				"https://api.twitter.com/1.1/statuses/update.json",
				{:status => texte}
			)
		end
		
		unless reponse == Net::HTTPSuccess then
			reponse.value
		end
	end
	
	private
	
	##
	# Authentifie l'application auprès de Twitter pour l'username donné. Si
	# l'application n'est pas connue dans la base de données, appelle la méthode
	# auth_initiale_twitter.
	
	def auth_twitter(username)
		unless @id_bdd = $bdd.app("twitter.com", username, @session) then
			print "Clé d'API : "
			@session[:api_key] = gets.chomp
			print "Clé secrète d'API : "
			@session[:api_secret] = gets.chomp
		end
		consumer = OAuth::Consumer.new(@session[:api_key],
		                               @session[:api_secret],
		                               {:site => @url_base,
		                               :scheme => :header})
		request_token = consumer.get_request_token(:oauth_callback => 'oob')
		@session[:oauth_token] = request_token.token
		@session[:oauth_token_secret] = request_token.secret
		url = request_token.authorize_url(:oauth_callback => 'oob')
		
		# Demande à l'utilisateur d'ouvrir l'URL, d'autoriser l'application et
		# d'écrire le code obtenu dans le terminal
		
		puts "Ouvrez " + url + " dans votre navigateur et autorisez " +
			"l'application."
		print "Code obtenu : "
		@session[:oauth_verifier] = gets.chomp
		hash = {
			oauth_token: @session[:oauth_token],
			oauth_token_secret: @session[:oauth_token_secret]
		}
		request_token = OAuth::RequestToken.from_hash(consumer, hash)
		@access_token = request_token.get_access_token(
			{:oauth_verifier => @session[:oauth_verifier],
		     :oauth_token => @session[:oauth_token],
		     :oauth_token_secret => @session[:oauth_token_secret]}
		)
		unless @id_bdd then
			reponse = @access_token.get(
				"https://api.twitter.com/1.1/account/settings.json"
			)
			username = JSON.parse(reponse.body)["screen_name"]
			@id_bdd = $bdd.enregistrer_app(ApiType::TWITTER,
			                               "twitter.com",
			                               username,
			                               @session[:api_key],
			                               @session[:api_secret])
		end
	end
	
end
