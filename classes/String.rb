require_relative 'Bot.rb'

##
# Ajout à la classe String de méthodes pour évaluer les expressions et modifier
# les chaînes de caractères.

class String
	
	##
	# Évalue les expressions présentes dans la chaîne de caractères. Les
	# expressions sont définies entre accolades <tt>{}</tt>.
	#
	# Les expressions peuvent être de différents types :
	# * Les affectations : <tt>{id=type(param1, param2)}</tt> enregistre à la
	#   clé +id+ de l'index un Element de type +type+ précisé par la liste de
	#   paramètres (exemple : <tt>{objet=pers}</tt> enregistre à la clé
	#   +_objet_+ de l'index un nouveau personnage).  
	#   L'expression est simplement supprimée de la chaîne. Si un élément est
	#   déjà présent à la clé donnée, une IndexError est levée.
	# * Les requêtes sur les éléments : <tt>{cle.attribut(param1,param2)}</tt>
	#   demande à l'élément à la clé +cle+ de l'index de retourner sa valeur
	#   +attribut+ avec la liste des paramètres donnés, et écrit le résultat à
	#   la place de l'expression. Appelle la méthode +retourner+ de l'élément.
	#   Exemple : <tt>{loc_lieu.nom(à)}</tt> écrit le nom de la localité
	#   enregistrée à la clé +_loc_lieu_+ avec la préposition <em>à</em>.  
	#   Lève une IndexError si la clé n'existe pas dans l'index.
	# * Les tests : <tt>{cle}</tt> teste si +cle+ existe dans l'index et lève
	#   une IndexError si elle n'existe pas. L'expression est simplement
	#   supprimée de la chaîne.
	def evaluer
		res = self
		rescom = nil
		while(res =~ /{[^{}]+}/) do
			res = res.gsub(/{[^{}]+}/) do | commande |
				rescom = commande.eval_expression
			end
		end
		return res
	end
	
	##
	# Modifie l'article en début de chaîne de caractères par l'article donné
	# (retourne une copie de la chaîne, String).
	#
	# Les apostrophes doivent être typographiques (<em>’</em>, pas <em>'</em>)
	# pour être reconnues.
	#
	# Les valeurs d'<tt>article</tt> prises en charge sont :
	# [+nil+]           Aucune modification de la chaîne.
	# [<tt>"0"</tt>]    Supprime l'éventuel article (_le_, _la_, _l’_, _un_,
	#                   _une_) en début de chaîne.
	# [<tt>"le"</tt>]   Article défini, remplacé par _le_, _la_, _l’_ ou ignoré
	#                   selon l'article indéfini (_un_, _une_) déjà présent en
	#                   début de la chaîne.
	# [<tt>"de"</tt>]   Préposition, contractée avec _le_ ou une éventuelle
	#                   voyelle en début de chaîne, ou ajoutée telle quelle.
	# [<tt>"à"</tt>]    Préposition, contractée avec _le_ ou ajoutée telle
	#                   quelle.
	# [<tt>"en"</tt>]   Préposition, contractée avec _le_, remplaçant _la_ ou
	#                   _l’_ ou ajoutée telle quelle.
	# [Autre valeur]    Ajout de la valeur passée en paramètre au début de la
	#                   chaîne, suivie d'une espace.
	def modif_article(article)
		case article
			
		# aucune modification de la chaîne
		when nil
			return self
			
		# article défini
		when "le"
			# masculin
			if(self =~ /^un /i) then
				# nom commençant par une voyelle
				if(self =~ /^un [aeiouyéèàêâôûùïî]/i) then
					return self.gsub(/^un /i, "l’")
				else # nom commençant par une consonne
					return self.gsub(/^un/i, "le")
				end
			# féminin
			elsif(self =~ /^une /i) then
				# nom commençant par une voyelle
				if(self =~ /^une [aeiouyéèàêâôûùïî]/i) then
					return self.gsub(/^une /i, "l’")
				else # nom commençant par une consonne
					return self.gsub(/^une/i, "la")
				end
			# la chaîne n'a pas d'article reconnu à remplacer : on ne la modifie
			# pas
			else
				return self
			end
		# Préposition "de"
		when "de"
			# Contraction avec "le"
			if(self =~ /^le [^aeiouyéèàêâôûùïî]/i) then
				return self.gsub(/^le/i, "du")
			# Devant une voyelle
			elsif(self =~ /^[aeiouyéèàêâôûùïî]/i) then
				return self.gsub(/^/, "d’")
			# Ajout du "de" sans modifications
			else
				return self.gsub(/^/, "de ")
			end
			
		# Préposition "à"
		when "à"
			# Contraction avec "le"
			if(self =~ /^le /i) then
				return self.gsub(/^le/i, "au")
			# Ajout du "à" sans modification
			else
				return self.gsub(/^/, "à ")
			end
		
		# Préposition "en"
		when "en"
			# Contraction avec "le"
			if(self =~ /^le /i) then
				return self.gsub(/^le/i, "au")
			# Contraction avec "la"
			elsif(self =~ /^la /i) then
				return self.gsub(/^la/i, "en")
			# Contraction avec "l'"
			elsif(self =~ /^l’/i) then
				return self.gsub(/^l’/i, "en ")
			# Ajout du "en" sans modification
			else
				return self.gsub(/^/, "en ")
			end
			
		# Suppression de l'article en début de chaîne
		when "0"
			return self.gsub(/^(un |une |le |la |l’)/i, "")
			
		# Ajout de l'article donné au début de la chaîne
		else
			return article + " " + self
		end
	end
	
	##
	# Met la première lettre de la chaîne en majuscule sans toucher aux autres
	# (contrairement à String#capitalize). Retourne une copie de la chaîne
	# (String).
	def majuscule
		return self.gsub(/^\w/) {|c| c.upcase}
	end
	
	protected
	
	##
	# Évalue l'expression représentée par la chaîne de caractères, commençant
	# par <tt>{</tt> et finissant par <tt>}</tt>.
	def eval_expression
		begin
			# Nom de la variable à affecter
			if(self =~ /{\w+=/) then
				nouv_var = self.scan(/{\w+=/)[0].scan(/\w+/)[0]
				# Commande principale
				com = self.scan(/=\w+/)[0].scan(/\w+/)[0]
			else
				com = self.scan(/{\w+/)[0].scan(/\w+/)[0]
			end
			
			# Attribut
			if(self =~ /\.\w+/) then
				attribut = self.scan(/\.\w+/)[0].scan(/\w+/)[0]
			end
			
			# Paramètres
			parametres = []
			if(self =~ /\([^\(\)]*\)/) then
				parametres = self.scan(/[\,\(][^\(\)\,]*/)
				parametres.each do | param |
					param.gsub!(/^[\,\(]/, "")
				end
			end
			
			# Demande à l'index
			if(Bot.index[com] == nil) then
				raise IndexError, "#{com} (#{self}) n'existe pas dans l'index"
			end
			resultat = Bot.index[com].retourner(attribut, parametres)
			if(nouv_var) then
				if(Bot.index[nouv_var] == nil) then
					Bot.index[nouv_var] = resultat
				else
					raise IndexError, "#{nouv_var} (#{self}) existe déjà " + 
							"dans l'index (#{Bot.index[nouv_var]})"
				end
				return ""
			else
				return resultat.to_s
			end
		end
	end
	
end
