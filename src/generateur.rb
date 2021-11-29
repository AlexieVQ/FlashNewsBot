require "rosace"
require_relative "entites/action"
require_relative "entites/info"
require_relative "entites/pers"
require_relative "entites/decla"
require_relative "entites/acteur"
require_relative "entites/media"
require_relative "entites/surnom"
require_relative "entites/lieu"
require_relative "entites/entreprise"

GENERATEUR = Rosace::Generator.new(
	path: "regles/",
	rules: [
		Action,
		Info,
		Pers,
		Decla,
		Media,
		Surnom,
		Lieu,
		Entreprise
	],
	functions: [
		Rosace::Function.new(:emoji_pays, ->(arg) { arg }),
		Rosace::Function.new(:h, ->(arg) do
			Rosace::ContextualValue.new(rand(2) == 1 ? "#" : "", arg.context)
		end),
		Rosace::Function.new(
			:new_acteur,
			->(nom, genre = nil, nombre = nil, personne = nil) do
				Rosace::ContextualValue.new(
					Acteur.new(
						nom: nom.value,
						genre: genre ? genre.value.to_sym : :M,
						nombre: nombre ? nombre.value.to_sym : :S,
						personne: personne ? personne.value.to_i : 3
					),
					nom.context
				)
			end
		),
		Rosace::Function.new(
			:que,
			->(phrase) do
				Rosace::ContextualValue.new(
					(phrase.value =~ /\A[aeiou]/i ? "qu’" : "que ") +
							phrase.value,
					phrase.context
				)
			end
		)
	]
)

def generer
	context = GENERATEUR.new_evaluation_context
	context.pick_entity(:Main).value
end