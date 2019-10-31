-- Commandes de création de la base de données

-- Table contenant les accroches
CREATE TABLE accroche (
	id SERIAL PRIMARY KEY,
	accroche VARCHAR(280) NOT NULL,
	poids INTEGER NOT NULL DEFAULT 10
);

-- Table contenant les structures de status
CREATE TABLE structure (
	id SERIAL PRIMARY KEY,
	structure VARCHAR(280) NOT NULL,
	poids INTEGER NOT NULL DEFAULT 10
);

-- Genre grammatical d'une personne
CREATE TYPE genre AS ENUM ('M', 'F');

-- Personne
CREATE TABLE pers (
	id SERIAL PRIMARY KEY,
	nom_colle VARCHAR(280) UNIQUE NOT NULL,
	poids INTEGER NOT NULL DEFAULT 10,
	genre GENRE NOT NULL
);

-- Nom d'une personne
CREATE TABLE nom_pers (
	id SERIAL PRIMARY KEY,
	nom VARCHAR(280) NOT NULL,
	poids INTEGER NOT NULL DEFAULT 10,
	id_pers INTEGER NOT NULL REFERENCES pers(id)

);

-- Surnom d'une personne
CREATE TABLE surnom (
	id SERIAL PRIMARY KEY,
	surnom VARCHAR(240) NOT NULL,
	poids INTEGER NOT NULL DEFAULT 10,
	id_pers INTEGER NOT NULL REFERENCES pers(id)
);

-- Parti politique ou syndicat
CREATE TABLE parti (
	id SERIAL PRIMARY KEY,
	nom VARCHAR(280) NOT NULL,
	sigle VARCHAR(280) NOT NULL,
	poids INTEGER NOT NULL DEFAULT 10,
	adjm VARCHAR(280),
	adjf VARCHAR(280)
);

-- Média (papier, TV, radio, internet…)
CREATE TABLE media (
	id SERIAL PRIMARY KEY,
	nom VARCHAR(280) NOT NULL,
	poids INTEGER NOT NULL DEFAULT 10
);

-- Date d'un information
CREATE TABLE date (
	id SERIAL PRIMARY KEY,
	date VARCHAR(280) NOT NULL,
	poids INTEGER NOT NULL DEFAULT 10
);

-- Lieu d'une information
CREATE TABLE lieu (
	id SERIAL PRIMARY KEY,
	lieu VARCHAR(280) NOT NULL,
	poids INTEGER NOT NULL DEFAULT 10
);

-- Type de localité
CREATE TYPE type_localite AS ENUM ('ville', 'pays', 'region');

-- Localité (ville, pays, région)
CREATE TABLE localite (
	id SERIAL PRIMARY KEY,
	nom VARCHAR(280) NOT NULL,
	nom_colle VARCHAR(280) NOT NULL,
	poids INTEGER NOT NULL DEFAULT 10,
	adjm VARCHAR(280),
	adjf VARCHAR(280),
	departement VARCHAR(280),
	type TYPE_LOCALITE NOT NULL
);

-- Type d'une circonstance
CREATE TYPE type_circo AS ENUM (
	'specifique',	-- Circonstance spécifique à une information
	'universel',	-- Circonstance utilisable dans tous les contextes
	'accuse',		-- Quand le sujet accuse une personne
	'est_accuse'	-- Quand le sujet est accusé par quelqu'un d'autre
);

-- Information
CREATE TABLE info (
	id SERIAL PRIMARY KEY,
	type VARCHAR(280) NOT NULL,
	description VARCHAR(280),		-- Pour faciliter la lecture de la base, non
									-- utilisé par le bot
	type_circo TYPE_CIRCO NOT NULL
);

-- Action d'une information
CREATE TABLE action (
	id SERIAL PRIMARY KEY,
	action VARCHAR(280) NOT NULL,
	poids INTEGER NOT NULL DEFAULT 10,
	id_info INTEGER NOT NULL REFERENCES info(id)
);

-- Circonstance d'une information
CREATE TABLE circo (
	id SERIAL PRIMARY KEY,
	circo VARCHAR(280) NOT NULL,
	poids INTEGER NOT NULL DEFAULT 10,
	type TYPE_CIRCO NOT NULL,
	id_info INTEGER REFERENCES info(id)
);

-- Déclaration du sujet à propos de l'information
CREATE TABLE decla (
	id SERIAL PRIMARY KEY,
	decla VARCHAR(280) NOT NULL,
	poids INTEGER NOT NULL DEFAULT 10,
	id_info INTEGER REFERENCES info(id)
);

-- Type du réseau social
CREATE TYPE type_app AS ENUM ('twitter', 'mastodon');

-- Application
CREATE TABLE application (
	id SERIAL PRIMARY KEY,
	type TYPE_APP NOT NULL,
	domaine VARCHAR(64) UNIQUE NOT NULL,
	api_key VARCHAR(256),
	api_secret VARCHAR(256),
	oauth_token VARCHAR(256),
	oauth_token_secret VARCHAR(256)
);

-- Historique des status envoyés, avec leurs statistiques et les éléments
-- utilisés
CREATE TABLE historique (
	id BIGINT NOT NULL,
	id_app INTEGER NOT NULL REFERENCES application(id),
	PRIMARY KEY (id, id_app),
	date TIMESTAMPTZ NOT NULL,
	nb_partages INTEGER NOT NULL DEFAULT 0,
	nb_likes INTEGER NOT NULL DEFAULT 0,
	nb_reponses INTEGER NOT NULL DEFAULT 0,
	id_info INTEGER NOT NULL REFERENCES info(id),
	id_structure INTEGER NOT NULL REFERENCES structure(id)
);

-- Personnes citées dans un status
CREATE TABLE historique_pers (
	id_status BIGINT NOT NULL,
	id_app INTEGER NOT NULL REFERENCES application(id),
	id_pers INTEGER NOT NULL REFERENCES pers(id),
	PRIMARY KEY (id_status, id_app, id_pers)
);
