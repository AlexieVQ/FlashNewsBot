##
# Ajout à la classe String de la méthode évaluer, qui évalue une commande entre
# {} dans un élément.

class String
	
	## Évalue les commandes entre {}
	def evaluer
		res = self
		rescom = nil
		while res =~ /{[^{}]+}/ do
			res = res.gsub(/{[^{}]+}/) do | commande |
				unless rescom = commande.eval_commande then
					raise "Erreur en essayant d'évaluer #{commande} dans #{self}"
				end
				rescom
			end
		end
		return res
	end
	
	## Évaluer une commande
	def eval_commande
		# Nom de la variable à affecter
		if self =~ /{\w+=/ then
			nouv_var = self.scan(/{\w+=/)[0].scan(/\w+/)[0]
			# Commande principale
			com = self.scan(/=\w+/)[0].scan(/\w+/)[0]
		else
			com = self.scan(/{\w+/)[0].scan(/\w+/)[0]
		end
		
		# Attribut
		if self =~ /\.\w+/ then
			attribut = self.scan(/\.\w+/)[0].scan(/\w+/)[0]
		end
		
		# Paramètres
		parametres = []
		if self =~ /\([^\(\)]*\)/ then
			parametres = self.scan(/\([^\(\)]*\)/)[0].scan(/[^\(\)\,]+/)
		end
		
		# Demande à l'index
		if $index[com] == nil then
			return nil
		end
		resultat = $index[com].retourner(attribut, parametres)
		if nouv_var then
			if $index[nouv_var] == nil then
				$index[nouv_var] = resultat
			end
			return ""
		else
			return resultat.to_s
		end
	end
	
	##
	# Modifie l'article en début de chaîne en l'article passé en paramètre.  
	# Articles supportés :
	# - "le"
	# - "de"
	# - "à"
	# - "en"
	# - "0" pour supprimer l'article en début de chaîne
	def modif_article(article)
		case article
			
		when nil
			return self
			
		when "le"
			if self =~ /^un / then
				if self =~ /^un [aeiouyéèàêâôûùïî]/ then
					return self.gsub(/^un /, "l’")
				else
					return self.gsub(/^un/, "le")
				end
			elsif self =~ /^une / then
				if self =~ /^une [aeiouyéèàêâôûùïî]/ then
					return self.gsub(/^une /, "l’")
				else
					return self.gsub(/^une/, "la")
				end
			else
				return self
			end
			
		when "de"
			if self =~ /^le [^aeiouyéèàêâôûùïî]/ then
				return self.gsub(/^le/, "du")
			elsif self =~ /^[aeiouyéèàêâôûùïî]/ then
				return self.gsub(/^/, "d’")
			else
				return self.gsub(/^/, "de ")
			end
			
		when "à"
			if self =~ /^le / then
				return self.gsub(/^le/, "au")
			else
				return self.gsub(/^/, "à ")
			end
			
		when "en"
			if self =~ /^le / then
				return self.gsub(/^le/, "au")
			elsif self =~ /^la / then
				return self.gsub(/^la/, "en")
			elsif self =~ /^l’/ then
				return self.gsub(/^l’/, "en ")
			else
				return self.gsub(/^/, "en ")
			end
			
		when "0"
			return self.gsub(/^(un |une |le |la |l’)/, "")
			
		else
			return article + " " + self
		end
	end
	
end
