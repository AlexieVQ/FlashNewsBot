require "i18n"
require "levenshtein-ffi"

I18n.config.available_locales = :en

module Refinements

	refine String do

		# Met la première lettre en majuscule sans changer le reste.
		# @return [String] Cette chaîne avec le premier caractère en majuscule
		def majuscule
			self[0].upcase + self[1, length]
		end

		# @return [Boolean]
		def voyelle?
			/\A([aeiou]|y([^aeiou]|\z))/i.match?(I18n.transliterate(self))
		end

		# Calcule la distance de Levenshtein avec la chaîne donnée.
		# Le test est insensible à la case et aux accents.
		# @param chaine [String] Chaîne à comparer
		# @return [Integer] Nombre d'insertion, suppression ou remplacements
		#  entre les deux chaînes.
		def levenshtein(chaine)
			s1 = I18n.transliterate(self).downcase
			s2 = I18n.transliterate(chaine).downcase
			l = Levenshtein.distance(s1, s2)
			puts "s1 = #{s1}, s2 = #{s2}, d = #{l}"
			l
		end

	end
end