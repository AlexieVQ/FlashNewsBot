##
# Ajout à la classe String de la méthode évaluer, qui évalue une commande entre
# {} dans un élément.

class String
	
	## Évalue les commandes entre {}
	def evaluer
		while self.scan(/{[^{}]+}/).length do
			self.gsub(/{[^{}]+}/) do | commande |
				commande.eval_commande
			end
		end
	end
	
	## Évaluer une commande
	def eval_commande
		# Nom de la variable à affecter
		if self.scan(/{\w+=/).length do
			nouv_var = self.scan(/{\w+=/)[0].scan(/\w/)[0]
			# Commande principale
			com = self.scan(/=\w+/)[0].scan(/\w/)[0]
		else
			com = self.scan(/{\w+/)[0].scan(/\w/)[0]
		end
		
		# Attribut
		if self.scan(/\.\w+/) do
			attribut = self.scan(/\.\w+/)[0].scan(/\w/)[0]
		end
		
		# Paramètres
		parametres = []
		if self.scan(/\([^\(\)]*\)/) do
			parametres = self.scan(/\([^\(\)]*\)/)[0].scan(/[^\(\)\,]+/)
		end
		
		# Demande à l'index
		resultat = $index[com].retourner(attribut, parametres)
		if nouv_var do
			if $index[nouv_var] == nil do
				$index[nouv_var] = resultat
			else
				raise "#{nouv_var} existe déjà dans l'index"
		else
			return resultat.to_s
		end
	end
	
end
