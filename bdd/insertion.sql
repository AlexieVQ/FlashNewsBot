-- Insertion des valeurs dans la table

INSERT INTO accroche(accroche, poids) VALUES
	('BREAKING', 10),
	('BREAKING NEWS', 10),
	('FLASH', 10),
	('FLASH NEWS', 10),
	('DIRECT', 10),
	('EXCLUSIVITÉ', 8),
	('ALERTE INFO -', 15),
	('SCOOP', 5),
	('C’est officiel :', 5);
	
INSERT INTO structure(structure, poids) VALUES
	('{emoji} {accroche} {sujet.nom} {info.action}.', 30),
	('{emoji} {accroche} {sujet.nom} {info.action} {rand({date},{lieu})}.', 10),
	('{emoji} {accroche} {sujet.nom} {info.action} {date} {lieu}.', 10),
	('{emoji} {accroche} {sujet.nom} {info.action} {info.circo}.', 10),
	('{emoji} {accroche} {sujet.nom} {info.action} {rand({date},{lieu})} {info.circo}.', 10),
	('{emoji} {accroche} {sujet.nom} {info.action} {date} {lieu} {info.circo}.', 10),
	('{emoji} {accroche.sans(:)} {sujet.nom} : {sujet.surnom} {info.action}.', 30),
	('{emoji} {accroche.sans(:)} {sujet.nom} : {sujet.surnom} {info.action} {rand({date},{lieu})}.', 10),
	('{emoji} {accroche.sans(:)} {sujet.nom} : {sujet.surnom} {info.action} {date} {lieu}.', 10),
	('{emoji} {accroche.sans(:)} {sujet.nom} : {sujet.surnom} {info.action} {info.circo}.', 10),
	('{emoji} {accroche.sans(:)} {sujet.nom} : {sujet.surnom} {info.action} {rand({date},{lieu})} {info.circo}.', 10),
	('{emoji} {accroche.sans(:)} {sujet.nom} : {sujet.surnom} {info.action} {date} {lieu} {info.circo}.', 10);
