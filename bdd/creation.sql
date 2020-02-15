-- Commandes de création de la base de données

-- Table des Compte
CREATE TABLE comptes (
	id SERIAL PRIMARY KEY,
	username VARCHAR(64) NOT NULL,
	domaine VARCHAR(64) NOT NULL,
	UNIQUE (username, domaine)
);

-- Table des CompteTwitter (spécialisation des Compte)
CREATE TABLE comptes_twitter (
	compte_id INTEGER PRIMARY KEY REFERENCES comptes(id),
	username VARCHAR(64) NOT NULL,
	api_key VARCHAR(64),
	api_secret VARCHAR(64)
);

-- Historique des status envoyés, avec leurs statistiques et les éléments
-- utilisés
CREATE TABLE statuses (
	id BIGINT NOT NULL,
	compte_id INTEGER NOT NULL REFERENCES comptes(id),
	PRIMARY KEY (id, compte_id),
	created_at TIMESTAMPTZ NOT NULL,
	id_info INTEGER NOT NULL,
	partages INTEGER,
	likes INTEGER,
	reponses INTEGER,
	citations INTEGER
);

-- Historique des personnages envoyés dans les status
CREATE TABLE pers (
	status_id INTEGER NOT NULL,
	compte_id INTEGER NOT NULL,
	id_pers INTEGER NOT NULL,
	FOREIGN KEY (status_id, compte_id) REFERENCES statuses(id, compte_id),
	PRIMARY KEY (status_id, compte_id, id_pers)
);
