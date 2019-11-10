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
	attr :instance, false
	
	# @url_base		=> URL de base de l'API (ex : https://api.twitter.com)
	# @session		=> Stockage des tokens
	# @access_token	=> Token d'accès à l'API
	# @id_bdd		=> ID de l'app dans la base
	
	private_class_method :new
	
	##
	# Connexion à l'API.
	#
	# Paramètres :
	# - type : ApiType::TWITTER
	# - nom_instance : "twitter.com"
	# - cle_api = Clé d’API de l’application crée sur developer.twitter.com
	# - cle_secret = Clé secrète d’API de l’application
	
	def Api.connecter(type = ApiType::TWITTER,
	                  nom_instance = "twitter.com",
	                  cle_api,
	                  cle_secret)
		new(type, nom_instance, cle_api, cle_secret)
	end
	
	## Méthode privée
	def initialize(type, nom_instance, cle_api, cle_secret)
		@session = Hash.new
		@type = type
		case type
		when ApiType::TWITTER
			@instance = "twitter.com"
			@url_base = "https://api.twitter.com"
			auth_initiale_twitter(cle_api, cle_secret)
		end
	end
	
	##
	# Envoie un statut sur le réseau social.
	
	def envoyer(texte)
		case @type
		when ApiType::TWITTER
			reponse = @access_token.post(
				"https://api.twitter.com/1.1/statuses/update.json",
				{:status => texte}
			)
			puts reponse.body
		end
	end
	
	private
	
	##
	# Authentifie l'application auprès de Twitter pour la paire de clés données
	# pour un utilisateur. Il sera demandé à l'utilisateur de se connecter à
	# Twitter sur le navigateur et de rentrer dans le terminal le code fourni.
	#
	# Retourne un access_token, qui sera utilisé pour les appels à l'API.
	
	def auth_initiale_twitter(cle_api, cle_secret)
		
		consumer = OAuth::Consumer.new(cle_api,
		                               cle_secret,
		                               {:site => @url_base, :scheme => :header})
		request_token = consumer.get_request_token(:oauth_callback => 'oob')
		@session[:token] = request_token.token
		@session[:token_secret] = request_token.secret
		url = request_token.authorize_url(:oauth_callback => 'oob')
		
		# Demande à l'utilisateur d'ouvrir l'URL, d'autoriser l'application et
		# d'écrire le code obtenu dans le terminal
		
		puts "Ouvrez " + url + " dans votre navigateur et autorisez " +
			"l'application."
		print "Code obtenu : "
		code = gets.chomp
		
		hash = {
			oauth_token: @session[:token],
			oauth_token_secret: @session[:token_secret]
		}
		request_token = OAuth::RequestToken.from_hash(consumer, hash)
		
		@access_token = request_token.get_access_token(
			{:oauth_verifier => code,
		     :oauth_token => @session[:token],
		     :oauth_token_secret => @session[:token_secret]})
		
		@id_bdd = $bdd.enregistrer_app(ApiType::TWITTER,
		                               "twitter.com",
		                               cle_api,
		                               cle_secret,
		                               @session[:token],
		                               @session[:token_secret])
	end
end
