-- Commandes de création de la base de données

-- Table des Api
CREATE TABLE apis (
	id SERIAL PRIMARY KEY
);

-- Table des TwitterApi (spécialisation des Api)
CREATE TABLE twitter_apis (
	api_id INTEGER PRIMARY KEY REFERENCES apis(id),
	username VARCHAR(64) NOT NULL,
	api_key VARCHAR(64),
	api_secret VARCHAR(64)
);

-- Historique des status envoyés, avec leurs statistiques et les éléments
-- utilisés
CREATE TABLE statuses (
	id BIGINT NOT NULL,
	api_id INTEGER NOT NULL REFERENCES apis(id),
	PRIMARY KEY (id, api_id),
	date TIMESTAMPTZ NOT NULL,
	id_info INTEGER NOT NULL,
	partages INTEGER,
	likes INTEGER,
	reponses INTEGER,
	citations INTEGER
);

-- Historique des personnages envoyés dans les status
CREATE TABLE historique_pers (
	status_id INTEGER NOT NULL,
	api_id INTEGER NOT NULL,
	id_pers INTEGER NOT NULL,
	FOREIGN KEY (status_id, api_id) REFERENCES statuses(id, api_id),
	PRIMARY KEY (status_id, api_id, id_pers)
);
