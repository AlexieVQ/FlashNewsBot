require_relative 'Bot.rb'
require_relative 'Expression.rb'
require_relative 'elements/Pers.rb'

##
# Un status à envoyer au réseau social. Il se construit aléatoirement à la
# création.

class Status
	
	#############
	# ATTRIBUTS #
	#############
	
	##
	# Texte du status (String)
	attr_reader :texte
	
	##
	# Information principale du status (Info)
	attr_reader :info
	
	##
	# Array de Pers présentes dans le status
	attr_reader :pers
	
	##
	# Images du status (Array d'Images)
	attr_reader :images
	
	################
	# CONSTRUCTEUR #
	################
	
	##
	# Crée un nouveau status de manière aléatoire.
	#
	# L'index est d'abord réinitialisé (voir Bot::index_reset). Une information
	# est stockée dans son entrée +info+. Si l'information a une structure
	# personnalisée (voir Info#structure), celle-ci est évaluée. Sinon un
	# personnage sujet de l'information est stocké dans +sujet+. L'action de
	# l'information (voir Info#action) est évaluée, avec possible ajout d'une
	# DateInfo et d'un Lieu. Ensuite une Accroche est ajouté en début de status,
	# puis une deuxième partie où le sujet réagit à l'information est
	# aléatoirement ajoutée, ou non. Cette partie incorpore Info#decla,
	# Pers#declas ou une déclaration universelle.
	def initialize
		begin
			Bot.index_reset
			
			# Choix de l'information principale du status
			Bot.index['info'] = Info.elt_alea
			
			# Cas où l'information a une structure personnalisée : on évalue la
			# structure
			if(Bot.index['info'].structure && Bot.index['info'].structure != "")
			then
				@texte = Bot.index['info'].structure.evaluer
			else
				# Choix du personnage sujet de l'information
				Bot.index['sujet'] = Pers.elt_alea
				
				# Génération de la partie information
				@texte = partie_info
				# Ajout de l'accroche
				@texte = Accroche.retourner(nil, [@texte, "sujet"])
				# Ajout de la deuxième partie du status, où le sujet prend la
				# parole
				if(rand(2) == 1) then
					@texte += " " + partie_decla
				end
			end
			@info = Bot.index['info']
			@pers = Bot.index.reduce([]) do |liste, tuple|
				if(tuple[1].kind_of? Pers) then
					liste << tuple[1]
				end
				liste
			end
			
			@images = []
			if(Bot.index['sujet'] && Bot.index['sujet'].image) then
				@images << Bot.index['sujet'].image
			end
			if(Bot.index['info'].image) then
				@images << Bot.index['info'].image
			elsif(Bot.index['objet'] && Bot.index['objet'].image) then
				@images << Bot.index['objet'].image
			end
			
		rescue IndexError => e
			puts "#{e.message} : réessai"
			retry
		end
	end
	
	############
	# MÉTHODES #
	############
	
	##
	# Représente le status sous la forme <tt>_Texte du status_ [_Description de
	# de l'image_ _URL de l'image]</tt>.
	def to_s
		return @images.reduce("#{@texte}") do |chaine, image|
			chaine + " " + image
		end
	end
	
	private
	
	# Génère la partie principale contenant l'action de l'information et
	# éventuellement sa circonstance, son lieu...  
	# Le sujet n'est pas nommé.
	def partie_info
		chaine = Bot.index['info'].action
		
		if(rand(2) == 1) then
			chaine += " " + Bot.index['date'].retourner.date
		end
		
		if(rand(2) == 1) then
			chaine += " " + Bot.index['lieu'].retourner.lieu
		end
		
		if(["accuse", "est_accuse",
		   "accusation"].include?(Bot.index['info'].type_circo) ||
		   rand(2) == 1) then
			chaine += " " + Bot.index['info'].circo
		end
		
		return chaine + "."
	end
	
	# Génère la partie contenant la déclaration du sujet.
	def partie_decla
		chaine = Bot.index['sujet'].surnom.majuscule
		
		chaine += " " + case rand(3)
		when 0 then "a déclaré"
		when 1 then "aurait déclaré"
		when 2 then "aurait dit"
		end
		
		if(rand(2) == 1) then
			chaine += " " + Bot.index['date'].retourner.date
		end
		
		if(rand(2) == 1) then
			chaine += " " + Bot.index['media'].retourner.nom("à")
		end
		
		if(rand(2) == 1) then
			chaine += " " + Bot.index['circo'].retourner.circo
		end
		
		chaine += " “" + Bot.index['info'].decla + "”"
		return chaine + "."
	end
	
end
