require_relative "acteur"

class ActeurProxy
	
	include Acteur

	# @return [Acteur]
	attr_reader :acteur

	# @return [1, 2, 3]
	attr_reader :personne

	# @return [:M, :F]
	attr_reader :genre

	# @return [:S, :P]
	attr_reader :nombre

	# @param acteur [Acteur]
	# @param personne [1, 2, 3, nil]
	# @param genre [:M, :F, nil]
	# @param nombre [:S, :P, nil]
	def initialize(acteur, personne: nil, genre: nil, nombre: nil)
		@acteur = acteur
		@personne = personne || acteur.personne
		@genre = genre || acteur.genre
		@nombre = nombre || acteur.nombre
	end

	# @return [String]
	def nom
		acteur.nom
	end

	def to_1e_personne
		personne == 1 ?
			self :
			ActeurProxy.new(acteur, personne: 1, genre: genre, nombre: nombre)
	end

	def to_2e_personne
		personne == 2 ?
			self :
			ActeurProxy.new(acteur, personne: 2, genre: genre, nombre: nombre)
	end

	def to_3e_personne
		personne == 3 ?
			self :
			ActeurProxy.new(acteur, personne: 3, genre: genre, nombre: nombre)
	end

end