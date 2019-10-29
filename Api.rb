require 'net/http'
require 'oauth'
require 'json'

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
	
	attr_reader :type, :instance
	
	# @type			=> Type de réseau social, voir ApiType
	# @instance		=> Nom de domaine du réseau social (ex : twitter.com)
	# @url_base		=> URL de base de l'API (ex : https://api.twitter.com)
	# @session		=> Stockage des tokens
	
	private_class_method :new
	
	##
	# Connexion à l'API
	
	def Api.connecter(type, nomInstance = "twitter.com", cleApi, cleSecret)
		new(type, nomInstance, cleApi, cleSecret)
	end
	
	def initialize(type, nomInstance, cleApi, cleSecret)
		@session = Hash.new
		@type = type
		case type
		when ApiType::TWITTER
			@instance = "twitter.com"
			@url_base = "https://api.twitter.com"
			auth_initiale_twitter(cleApi, cleSecret)
		end
	end
	
	private
	
	def auth_initiale_twitter(cleApi, cleSecret)
		
		consumer = OAuth::Consumer.new(cleApi,
		                               cleSecret,
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
		
		access_token = request_token.get_access_token(
			{:oauth_verifier => code,
		     :oauth_token => @session[:token],
		     :oauth_token_secret => @session[:token_secret]})
		
		reponse = access_token.get("https://api.twitter.com/1.1/followers/list.json")
		puts reponse.body
	end
end
