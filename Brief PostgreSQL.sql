-- Creation de la table youcoders

CREATE TABLE youcoders (
    matricule VARCHAR(4) PRIMARY KEY, 
	full_name VARCHAR(15) NOT NULL,
	campus VARCHAR(15) NOT NULL, 
	classe VARCHAR(15) NOT NULL, 
	referentiel VARCHAR(15) NOT NULL, 
	nbr_competence NUMERIC(5) DEFAULT 0, 
	is_accepted boolean
);

-- Insertion des données

INSERT INTO youcoders VALUES ('P400','KAMAL BHF','Youssoufia','FEBE','CDA',14,true);
INSERT INTO youcoders VALUES ('P765','Mohammed ahmed','Safi','JEE','DWWM',8,true);
INSERT INTO youcoders VALUES ('P122','Amine amine','Safi','C#','CDA',14,false);
INSERT INTO youcoders VALUES ('P202','Yassine yassine','Youssoufia','PHP','CDA',14,true);
INSERT INTO youcoders VALUES ('P980','Don Reda','Safi','JEE','DWWM',8,false);
INSERT INTO youcoders VALUES ('P543','Salma Salma','Youssoufia','C#','AI',10,true);
INSERT INTO youcoders VALUES ('P307','Zakaria zakaria','Safi','FEBE','CDA',14,false);
INSERT INTO youcoders VALUES ('P199','Omar omar','Safi','JEE','AI',10,false);
INSERT INTO youcoders VALUES ('P387','Houssam houssam','Safi','FEBE','CDA',14,true);
INSERT INTO youcoders VALUES ('P566','Imane imane','Youssoufia','FEBE','CDA',14,true);

--Fonction exemple

CREATE OR REPLACE FUNCTION nbYoucoders(ville VARCHAR,status Boolean,seuil INT) RETURNS INTEGER AS $$
DECLARE
n INTEGER;
BEGIN
SELECT COUNT(*) INTO n FROM youcoders where is_accepted=status and campus = ville;
IF n < seuil THEN
RAISE EXCEPTION 'Trop de rattrapage (%) !', n;
ELSE
RETURN n;
END IF;
END
$$ LANGUAGE plpgsql;

--1ère fonction

CREATE OR REPLACE FUNCTION studentPerc(total INT) RETURNS INTEGER AS $$
DECLARE
n INTEGER;
percentage NUMERIC;
BEGIN
SELECT COUNT(*) INTO n FROM youcoders where campus='Youssoufia' and classe = 'FEBE';

percentage = (total * n)/100;

return percentage;

END
$$ LANGUAGE plpgsql;

--2émé fonction

CREATE OR REPLACE FUNCTION stSameRef(student VARCHAR) RETURNS INTEGER AS $$
DECLARE
sClasse VARCHAR;
n INTEGER;

BEGIN
SELECT classe INTO sClasse FROM youcoders where full_name=student;

SELECT COUNT(*) INTO n FROM youcoders where classe=sClasse;

return n;

END
$$ LANGUAGE plpgsql;

--1ère procédure stockée

CREATE OR REPLACE PROCEDURE changeStatus()
LANGUAGE SQL
AS $$
UPDATE youcoders
SET is_accepted  = true
WHERE campus  = 'Youssoufia'
$$;

--Appel du 1ère procédure stockée

CALL changeStatus()

--2éme procédure stockée

CREATE OR REPLACE PROCEDURE updateClasse()
LANGUAGE SQL
AS $$
UPDATE youcoders
SET classe  = 'DATA BI'
WHERE nbr_competence=14 AND matricule LIKE '%2%'
$$;

--Appel du 2éme procédure stockée

CALL updateClasse()

--Trigger

CREATE OR REPLACE FUNCTION update_false() RETURNS trigger AS $update_false$
    BEGIN
       UPDATE youcoders SET is_accepted = false;
       RETURN NEW;
    END;
$update_false$ LANGUAGE plpgsql;

CREATE TRIGGER update_false AFTER INSERT  ON youcoders
    FOR EACH ROW EXECUTE FUNCTION update_false();


--Insertion de donnée pour tester le Trigger

INSERT INTO youcoders VALUES ('P198','DAIF','SAFI','FEBE','CDA',14,true);

-- Reformulation de la table youcoders

--Creation de la table referentiel

CREATE TABLE referentiel (
    id INTEGER PRIMARY KEY, 
	name VARCHAR(15) NOT NULL
);

--Creation de la table classe

CREATE TABLE classe (
    id INTEGER PRIMARY KEY, 
	name VARCHAR(15) NOT NULL
);

--Creation de la table campus

CREATE TABLE campus (
    id INTEGER PRIMARY KEY, 
	name VARCHAR(15) NOT NULL
);

--Insertion de donnée dans la table campus

INSERT INTO campus VALUES (1,'Safi');
INSERT INTO campus VALUES (2,'Youssoufia');

--Insertion de donnée dans la table classe


INSERT INTO classe VALUES (1,'FEBE');
INSERT INTO classe VALUES (2,'JEE');
INSERT INTO classe VALUES (3,'C#');
INSERT INTO classe VALUES (4,'PHP');

--Insertion de donnée dans la table referentiel


INSERT INTO referentiel VALUES (1,'CDA');
INSERT INTO referentiel VALUES (2,'DWWM');
INSERT INTO referentiel VALUES (3,'AI');

--Creation de la nouvelle table mycoders avec les freign key des autres tables

CREATE TABLE mycoders (
    matricule VARCHAR(4) PRIMARY KEY, 
	full_name VARCHAR(15) NOT NULL,
	campus_id INTEGER NOT NULL, 
	classe_id INTEGER NOT NULL, 
	referentiel_id INTEGER NOT NULL, 
	nbr_competence NUMERIC(5) DEFAULT 0, 
	is_accepted boolean,
    CONSTRAINT fk_campus
      FOREIGN KEY(campus_id) 
	  REFERENCES campus(id),
    CONSTRAINT fk_classe
      FOREIGN KEY(classe_id) 
	  REFERENCES classe(id),
    CONSTRAINT fk_referentiel
      FOREIGN KEY(referentiel_id) 
	  REFERENCES referentiel(id)
);

--Insertion de donnée dans la table mycoders

INSERT INTO mycoders VALUES ('P400','KAMAL BHF',2,1,1,14,true);
INSERT INTO mycoders VALUES ('P765','Mohammed ahmed',1,2,2,8,true);
INSERT INTO mycoders VALUES ('P122','Amine amine',1,3,1,14,false);
INSERT INTO mycoders VALUES ('P202','Yassine yassine',2,4,1,14,true);
INSERT INTO mycoders VALUES ('P980','Don Reda',1,2,2,8,false);
INSERT INTO mycoders VALUES ('P543','Salma Salma',2,3,3,10,true);
INSERT INTO mycoders VALUES ('P307','Zakaria zakaria',1,1,1,14,false);
INSERT INTO mycoders VALUES ('P199','Omar omar',1,2,3,10,false);
INSERT INTO mycoders VALUES ('P387','Houssam houssam',1,1,1,14,true);
INSERT INTO mycoders VALUES ('P566','Imane imane',2,1,1,14,true);

--Tester les references avec la jointure

select * from mycoders INNER JOIN classe ON mycoders.classe_id = classe.id
select * from mycoders INNER JOIN campus ON mycoders.campus_id = campus.id
select * from mycoders INNER JOIN referentiel ON mycoders.referentiel_id = referentiel.id

-- Ecrire une fonction qui prend en paramétres un variable s de type VARCHAR qui represente le nom d'une classe et retourne
--le nombre des apprenants acceptés dans cette classe (Dans la table mycoders)

CREATE OR REPLACE FUNCTION accMycoders(s VARCHAR) RETURNS INTEGER AS $$
DECLARE
n INTEGER;
BEGIN
SELECT COUNT(*) INTO n FROM mycoders INNER JOIN classe ON mycoders.classe_id = classe.id where name=s AND is_accepted=true;
RETURN n;
END
$$ LANGUAGE plpgsql;

--Appel du fonction

SELECT accMycoders('FEBE')

--EXPECTED OUTPUT : 3
--RESULT: 3



















--           _
--       .__(.)< (SKETCH)
--        \___)
-- ~~~~~~~~~~~~~~~~~~-->