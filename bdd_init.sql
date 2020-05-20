-- Commandes de création de la base de données

-- Table des Compte
CREATE TABLE comptes (
	id BIGINT NOT NULL,
	domaine VARCHAR(64) NOT NULL,
	username VARCHAR(64) NOT NULL,
	PRIMARY KEY (id, domaine),
	UNIQUE (username, domaine)
);

-- Table des CompteTwitter (spécialisation des Compte)
CREATE TABLE comptes_twitter (
	compte_id BIGINT NOT NULL,
	domaine VARCHAR(64) NOT NULL,
	FOREIGN KEY (compte_id, domaine) REFERENCES comptes(id, domaine),
	PRIMARY KEY (compte_id, domaine),
	api_key VARCHAR(64),
	api_secret VARCHAR(64)
);

-- Historique des status envoyés, avec leurs statistiques et les éléments
-- utilisés
CREATE TABLE statuses (
	id BIGINT NOT NULL,
	compte_id BIGINT NOT NULL,
	domaine VARCHAR(64) NOT NULL,
	FOREIGN KEY (compte_id, domaine) REFERENCES comptes(id, domaine),
	PRIMARY KEY (id, compte_id, domaine),
	created_at TIMESTAMPTZ NOT NULL,
	id_info INTEGER NOT NULL,
	partages INTEGER,
	likes INTEGER,
	reponses INTEGER
);

-- Historique des mentions reçues
CREATE TABLE mentions (
	id BIGINT NOT NULL,
	compte_id BIGINT NOT NULL,
	domaine VARCHAR(64) NOT NULL,
	FOREIGN KEY (compte_id, domaine) REFERENCES comptes(id, domaine),
	PRIMARY KEY (id, compte_id, domaine)
);

-- Historique des personnages envoyés dans les status
CREATE TABLE pers (
	status_id BIGINT NOT NULL,
	compte_id BIGINT NOT NULL,
	domaine VARCHAR(64) NOT NULL,
	id_pers INTEGER NOT NULL,
	FOREIGN KEY (status_id, compte_id, domaine)
		REFERENCES statuses(id, compte_id, domaine),
	PRIMARY KEY (status_id, compte_id, domaine, id_pers)
);
