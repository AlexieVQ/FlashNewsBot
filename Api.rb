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
	# - domaine : "twitter.com"
	# - cle_api = Clé d’API de l’application crée sur developer.twitter.com
	# - cle_secret = Clé secrète d’API de l’application
	
	def Api.connecter(username,
	                  type = ApiType::TWITTER,
	                  domaine = "twitter.com",
	                  cle_api = nil,
	                  cle_secret = nil)
		new(username, type, domaine, cle_api, cle_secret)
	end
	
	## Méthode privée
	def initialize(username, type, domaine, cle_api = nil, cle_secret = nil)
		@session = Hash.new
		@type = type
		case type
		when ApiType::TWITTER then
			@instance = "twitter.com"
			@url_base = "https://api.twitter.com"
			auth_twitter(username, cle_api, cle_secret)
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
	
	def auth_twitter(username, cle_api = nil, cle_secret = nil)
		unless @id_bdd = $bdd.app("twitter.com", username, @session) then
			auth_initiale_twitter(cle_api, cle_secret)
		else
			consumer = OAuth::Consumer.new(@session[:api_key],
			                               @session[:api_secret],
			                               {:site => @url_base,
			                                :scheme => :header})
			request_token = consumer.get_request_token(:oauth_callback => 'oob')
			@session[:oauth_token] = request_token.token
			@session[:oauth_token_secret] = request_token.secret
			url = request_token.authorize_url(:oauth_callback => 'oob')
			
			# Demande à l'utilisateur d'ouvrir l'URL, d'autoriser l'application
			# et d'écrire le code obtenu dans le terminal
			
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
			$bdd.maj_app(@id_bdd,
			             @session[:oauth_token],
			             @session[:oauth_token_secret],
			             @session[:oauth_verifier])
		end
	end
	
	##
	# Authentifie l'application auprès de Twitter pour la paire de clés données
	# pour un utilisateur. Il sera demandé à l'utilisateur de se connecter à
	# Twitter sur le navigateur et de rentrer dans le terminal le code fourni.
	#
	# Retourne un access_token, qui sera utilisé pour les appels à l'API.
	
	def auth_initiale_twitter(cle_api = nil, cle_secret = nil)
		unless cle_api then
			print "Clé de l'API : "
			cle_api = gets.chomp
		end
		unless cle_secret then
			print "Clé secrète de l'API : "
			cle_secret = gets.chomp
		end
		
		consumer = OAuth::Consumer.new(cle_api,
		                               cle_secret,
		                               {:site => @url_base, :scheme => :header})
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
		     :oauth_token_secret => @session[:oauth_token_secret]})
		
		reponse = @access_token.get(
			"https://api.twitter.com/1.1/account/settings.json"
		)
#		if reponse == Net::HTTPSuccess then
			username = JSON.parse(reponse.body)["screen_name"]
			@id_bdd = $bdd.enregistrer_app(ApiType::TWITTER,
			                               "twitter.com",
			                               username,
			                               cle_api,
			                               cle_secret,
			                               @session[:oauth_token],
			                               @session[:oauth_token_secret],
			                               @session[:oauth_verifier])
#		else
#			reponse.value
#		end
	end
end
