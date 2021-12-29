require "rosace"
require_relative "refinements"
require_relative "entites/action"
require_relative "entites/info"
require_relative "entites/pers"
require_relative "entites/decla"
require_relative "entites/acteur"
require_relative "entites/media"
require_relative "entites/surnom"
require_relative "entites/lieu"
require_relative "entites/entreprise"
require_relative "entites/orga"
require_relative "entites/structure"
require_relative "entites/moment"

using Refinements

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
		Entreprise,
		Orga,
		Structure,
		Moment
	],
	functions: [
		Rosace::Function.new(:emojis_pays, ->(arg = nil) do
			Rosace::ContextualValue.new(
					arg.context.variable(:$info).emojis_pays, arg.context)
		end),
		Rosace::Function.new(:h, ->(arg = nil) do
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
					(phrase.value.voyelle? ? "qu’" : "que ") +
							phrase.value,
					phrase.context
				)
			end
		),
		Rosace::Function.new(
			:voy,
			->(phrase, si_voy, si_cons) do
				phrase.value.voyelle? ? si_voy : si_cons
			end,
			:concurrent
		),
		Rosace::Function.new(
			:puts,
			->(string) do
				puts string.value
				Rosace::ContextualValue.empty(string.context)
			end
		),
		Rosace::Function.new(
			:gn,
			->(acteur, ms, fs, mp, fp) do
				a = acteur.context.variable(acteur.value).gn(ms, fs, mp, fp)
			end,
			:concurrent
		),
		Rosace::Function.new(
			:rand,
			->(de, a) do
				Rosace::ContextualValue.new(
					rand(de.value.to_i..a.value.to_i).to_s,
					de.context
				)
			end
		),
		Rosace::Function.new(
			:si_implicite,
			->(acteur, alors, sinon) do
				# @type [Acteur]
				a = acteur.context.variable(acteur.value)
				a.implicite? ? alors : sinon
			end,
			:concurrent
		)
	]
)

GENERATEUR.print_messages

if GENERATEUR.failed?
	exit(1)
end

def generer
	context = GENERATEUR.new_evaluation_context
	context.pick_entity(:Main).value
end