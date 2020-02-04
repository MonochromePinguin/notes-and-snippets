-- ● REQUÊTES SIMPLES, REQUÊTES SYNCHRONES :
--

-- sous-requête simple :
SELECT * FROM EMPLOYE E
	WHERE E.NUMEMP NOT IN ( SELECT DISTINCT I.NUMEMP FROM INSCRIT I );

-- sous-requête synchrone :
-- LE DISTINCT N'EST PAS NÉCESSAIRE : VU QU'IL S'AGIT D'UNE SOUS-REQUÊTE SYNCHRONE,
-- LE MOTEUR DE SGBD VA SYSTÉMATIQUEMENT LIER ET OPTIMISER LES 2
SELECT E.NOMEMP FROM EMPLOYE E
	WHERE NOT EXISTS( SELECT DISTINCT I.NUMEMP FROM PARTICIPER I WHERE E.NUMEMP = I.NUMEMP );



-- récupère le nb de séminaires où M. Jolibois a été inscrit
SELECT COUNT(*) AS nbInscription FROM EMPLOYE E
   JOIN INSCRIT I ON E.NUMEMP = I.NUMEMP
   WHERE E.NOMEMP = 'Jolibois';



-- ... le nombre de liens dont la date de fin est armée à décembre 2099 pour chaque paire BAE/DRE
SELECT paire, count(*)
FROM (
  SELECT  BAE_ID || '/' || DRE_ID AS paire
  FROM LINK_BAE_DRE
  WHERE trunc( LBD_END_DATE, 'MONTH') = TO_DATE('20991201', 'YYYYMMDD')
  ORDER BY paire, LBD_START_DATE, LBD_END_DATE
)
GROUP BY paire
ORDER BY paire;


-- récupère tt les employé inscrits à un séminaire et leur nombre de séminaires
SELECT CONCAT(E.NOMEMP, ' ', E.PRENOMEMP) as employé, COUNT(*) AS Séminaires
	FROM EMPLOYE E
	JOIN INSCRIT I ON E.NUMEMP = I.NUMEMP
	GROUP BY employé
	ORDER BY Séminaires DESC;
--
-- LEFT JOIN : pareil, mais liste aussi les employés sans séminaires
-- RÉSULTAT : le 21e n'a pas de sémaire mais compte pour 1 : COUNT(*) == counte des lignes où l'employé est présent !
SELECT CONCAT(E.NOMEMP, ' ', E.PRENOMEMP) as employé, COUNT(*) AS Séminaires
	FROM EMPLOYE E
	LEFT JOIN INSCRIT I ON E.NUMEMP = I.NUMEMP
	GROUP BY employé
	ORDER BY Séminaires DESC;
-- BONNE VERSION : count(qqch) !
SELECT CONCAT(E.NOMEMP, ' ', E.PRENOMEMP) as employé, COUNT(I.NUMEMP) AS Séminaires
	FROM EMPLOYE E
	LEFT JOIN INSCRIT I ON E.NUMEMP = I.NUMEMP
	GROUP BY employé
	ORDER BY Séminaires DESC;



-- select all employee which had a seminary with Jolibois
SELECT DISTINCT E.NOMEMP nom FROM EMPLOYE E
	JOIN INSCRIT I ON E.NUMEMP = I.NUMEMP
	WHERE I.CODESEMI IN (
			 -- return all the seminary codes Jolibois attended
		 SELECT I.CODESEMI
				FROM INSCRIT I
				JOIN EMPLOYE E ON I.NUMEMP = E.NUMEMP
				WHERE E.NOMEMP = 'Jolibois'
	)
		AND E.NOMEMP <> 'Jolibois'
	ORDER BY nom;



-- noms des employés de salaire 12 000€ ayant participé à un séminaire
 SELECT E.NOMEMP
	FROM EMPLOYE E
	WHERE E.SALAIRE = 12000
			AND E.NUMEMP IN ( SELECT DISTINCT P.NUMEMP FROM PARTICIPER P );
-- la même, avec EXISTS()
SELECT E.NOMEMP
	FROM EMPLOYE E
	WHERE EXISTS( SELECT P.NUMEMP FROM PARTICIPER P
					WHERE E.NUMEMP = P.NUMEMP
						AND E.SALAIRE = 12000
			);


SELECT CONCAT(E.NOMEMP, ' ', E.PRENOMEMP) AS employé, E.NUMEMP, C.LIBELLECOURS AS Séminaire
	FROM EMPLOYE E
	LEFT JOIN INSCRIT I ON E.NUMEMP = I.NUMEMP
	JOIN SEMINAIRE S ON I.CODESEMI = S.CODESEMI
	JOIN COURS C ON S.CODECOURS = C.CODECOURS
	ORDER BY employé;

-- utilise le double-pipe comme opérateur de concaténation
set sql_mode=PIPES_AS_CONCAT;
SELECT E.NOMEMP || ' ' || E.PRENOMEMP AS employé, E.NUMEMP, C.LIBELLECOURS AS Séminaire
	FROM EMPLOYE E
	LEFT JOIN INSCRIT I ON E.NUMEMP = I.NUMEMP
	JOIN SEMINAIRE S ON I.CODESEMI = S.CODESEMI
	JOIN COURS C ON S.CODECOURS = C.CODECOURS
	ORDER BY employé;

-- GROUP_CONCAT() concatène ttes les lignes renvoyées par l'expression interne. il FAUT un GROUP BY
SELECT  E.NOMEMP || ' ' || E.PRENOMEMP AS employé,
		COUNT(DISTINCT C.LIBELLECOURS) as nbSém,
	GROUP_CONCAT( C.LIBELLECOURS SEPARATOR ', ●') séminaires
	FROM EMPLOYE E
		JOIN INSCRIT I ON E.NUMEMP = I.NUMEMP
		JOIN SEMINAIRE S ON I.CODESEMI = S.CODESEMI
	JOIN COURS C ON C.CODECOURS = S.CODECOURS
	GROUP BY employé
	ORDER BY employé;



-- liste les employés et leur projet associé
SELECT CONCAT( E.NOMEMP, ' ', E.PRENOMEMP ) nom, COALESCE(P.NOMPROJET, 'AUCUN') projet FROM EMPLOYE E
	LEFT JOIN PROJET P ON E.CODEPROJET = P.CODEPROJET
	GROUP BY nom, projet
	ORDER BY projet, nom;



-- liste le nombre et la liste des séminaires auquels participent les employés
SELECT CONCAT( E.NOMEMP, ' ', E.PRENOMEMP ) nom, COUNT(I.NUMEMP) `nb séminaires`, GROUP_CONCAT(
			C.LIBELLECOURS SEPARATOR ', ' )
	FROM EMPLOYE E
	JOIN INSCRIT I ON I.NUMEMP = E.NUMEMP
	JOIN SEMINAIRE S USING(CODESEMI)
	JOIN COURS C USING(CODECOURS)
	GROUP BY nom
	ORDER BY `nb séminaires` DESC;



-- sélectionne tt les employés inscrits à moins de 3 séminaires
SELECT E.NOMEMP nom, COUNT(I.NUMEMP) `nb séminaires` FROM INSCRIT I
	RIGHT JOIN EMPLOYE E ON E.NUMEMP = I.NUMEMP
	GROUP BY E.NUMEMP
	HAVING `nb séminaires` < 3
ORDER BY nom


-- list all clients with the minimum location count – with a variable
select @min := count(f.code_client) nb
	from facture f
	group by f.code_client
	order by nb asc
	limit 1;
select concat(c.nom, ' ', c.prenom) client,
		count(f.code_client) nbLoc
	from facture f
	join client c using(code_client)
	group by f.code_client
	having nbLoc <= @min
	order by nbLoc asc;



SET @MS = ( SELECT SUM(E.SALAIRE) FROM EMPLOYE E );
	SELECT E.NOMEMP AS nom, CONCAT(E.SALAIRE * 100 / @MS, '%') AS pourcentage FROM EMPLOYE E
	ORDER BY pourcentage;

-- CECI PASSE DANS MYSQL ET  SQLSERVER, MAIS DANS D'AUTRES SGBD, LE SUM() DE LA SOUS-REQUÊTE BLOQUE ET IMPLIQUE D'UTILISER UN « GROUP BY »
SELECT E.NOMEMP nom, E.SALAIRE * 100 / ( SELECT SUM(SALAIRE) FROM EMPLOYE )  AS pourcentage FROM EMPLOYE E
	ORDER BY pourcentage DESC;
-- → BONNE PRATIQUE :
SELECT E.NOMEMP nom, SUM(E.SALAIRE) * 100 / ( SELECT SUM(SALAIRE) FROM EMPLOYE ) AS pourcentage
	FROM EMPLOYE E
	GROUP BY nom
--    HAVING pourcentage > 5
	ORDER BY pourcentage ASC
	LIMIT 1;

-- employé de plus bas salaire
SELECT E.NOMEMP nom FROM EMPLOYE E
	order by e.salaire asc
	limit 1; ????


-- SELF JOIN : «auto jointure » via deux alias d'une même table.
-- C'EST COMME SI ON CRÉAIT UNE TABLE MIROIR

-- sélectionne tout les binômes possibles par pays – PAIRES REDONDANTES
SELECT C1.PAYS pays, LEAST(C1.NOM, C2.NOM) n1, GREATEST(C1.NOM, C2.NOM) n2 FROM COMMERCIAUX C1, COMMERCIAUX C2
	WHERE C1.IDCOMM <> C2.IDCOMM AND C1.PAYS = C2.PAYS
	ORDER BY pays, n1, n2;

-- sélectionne tout les binômes possibles par pays – REDONDANCE ÉVITÉE PAR UNE CONCATÉNATION
SELECT C1.PAYS pays, CONCAT( LEAST(C1.NOM, C2.NOM), ' & ', GREATEST(C1.NOM, C2.NOM) ) paire FROM COMMERCIAUX C1, COMMERCIAUX C2
 	WHERE C1.IDCOMM <> C2.IDCOMM AND C1.PAYS = C2.PAYS
	GROUP BY paire, pays
 	ORDER BY pays, paire;

--  sélectionne tout les binômes possibles par pays
SELECT C1.PAYS pays, LEAST(C1.NOM, C2.NOM) n1, GREATEST(C1.NOM, C2.NOM) n2 FROM COMMERCIAUX C1, COMMERCIAUX C2
	WHERE C1.IDCOMM < C2.IDCOMM AND C1.PAYS = C2.PAYS
	ORDER BY pays, n1, n2; ????

-- THETA JOIN – s'écrit avec un « INNER JOIN »
 SELECT E1.NOMEMP, E2.NOMEMP FROM EMPLOYE E1
 	INNER JOIN EMPLOYE E2 ON E1.SALAIRE < E2.SALAIRE
	ORDER BY E1.SALAIRE, E1.NOMEMP;



--● SUPPRIMER TOUTES LES LIGNES SURNUMÉRAIRES DONT CETTE COLONNE EST DOUBLONNÉE :
-- LISTE LES LIBELLÉS DOTÉS DE DOUBLONS :

-- 1) sélectionner les nombres de lignes et l'id (le plus bas) de la ligne à conserver :
SELECT
  ECHEANCE_LIBELLE libelle,
  count(*)         nb,
  min(ECHEANCE_ID) idConserve
FROM DIA_ECHEANCE
HAVING count(*) > 1
GROUP BY ECHEANCE_LIBELLE;

-- 2) LISTE LES LIGNES SURNUMÉRAIRES À SUPPRIMER :
WITH liste as (
  SELECT
    ECHEANCE_LIBELLE libelle,
    count(*)         nb,
    min(ECHEANCE_ID) idConserve
  FROM DIA_ECHEANCE
  HAVING count(*) > 1
  GROUP BY ECHEANCE_LIBELLE
)
SELECT *
FROM DIA_ECHEANCE e
where
  e.ECHEANCE_LIBELLE in (SELECT libelle FROM liste)
  and e.ECHEANCE_ID not in (SELECT idConserve FROM liste)
ORDER BY ECHEANCE_LIBELLE
;

-- 3) supprime toutes les lignes surnuméraires :
DELETE
FROM DIA_ECHEANCE
WHERE ECHEANCE_ID IN (
  WITH liste AS (
      SELECT
        ECHEANCE_LIBELLE libelle,
        min(ECHEANCE_ID) idConserve
      FROM DIA_ECHEANCE
      HAVING count(*) > 1
      GROUP BY ECHEANCE_LIBELLE
  )
  SELECT ECHEANCE_ID
  FROM DIA_ECHEANCE e
  WHERE
    e.ECHEANCE_LIBELLE IN (SELECT libelle
                           FROM liste)
    AND e.ECHEANCE_ID NOT IN (SELECT idConserve
                              FROM liste)
;



-- ORACLE : sélectionne les 𝑛 jours suivant une date :
SELECT (TO_DATE('01/06/2018', 'DD/MM/YYYY') + rownum - 1) AS JOUR
FROM ALL_OBJECTS
WHERE
  rownum <= 10
;
  
-- ORACLE : sélectionne les jours compris entre 2 dates
SELECT (TO_DATE('01/06/2018', 'DD/MM/YYYY') + rownum - 1) AS JOUR
FROM ALL_OBJECTS
WHERE
  rownum <= TO_DATE('10/06/2018', 'DD/MM/YYYY') -  TO_DATE('01/06/2018', 'DD/MM/YYYY')  +1
;




-- ORACLE : sélectionne tous les jours entre deux dates incluses, pour lesquels il existe
--  un lien RE-fournisseur ARENH valide pour le contrat donné,
-- puis y associe les complétions ARENH liées. Ceci permet
-- d'éviter de compter les courbes
-- absentes sur les jours dépourvus de lien valide.
--
-- sélectionne les jours compris entre les 2 dates fournies
WITH
dates as (
    SELECT (TO_DATE('01/06/2018', 'DD/MM/YYYY') + rownum - 1) AS JOUR
    FROM ALL_OBJECTS
    WHERE
      rownum <= TO_DATE('07/07/2018', 'DD/MM/YYYY') - TO_DATE('01/06/2018', 'DD/MM/YYYY') + 1
),
-- ne conserve que les jours pour lesquels le RE du contrat RE/GRD présente un lien avec un fournisseur ARENH
dates_avec_lien as (
    SELECT JOUR AS JOUR_AVEC_LIEN
    FROM dates
    WHERE
      EXISTS(
          SELECT 1
          FROM DIA_CONTRATS dc
            JOIN DIA_FOURNISSEUR_ARENH dfa ON dc.ID_ACTEUR1 = dfa.ID_ACTEUR
          WHERE
--             dc.CONTRAT_ID = 11416
            dc.contrat_id = 11579
            AND JOUR BETWEEN dfa.FOURN_DATE_DEBUT_ACTIVITE AND dfa.FOURN_DATE_FIN_ACTIVITE
    )
)
select
--   dates_avec_lien.JOUR_AVEC_LIEN DATE_COURBE,
  dates_avec_lien.JOUR_AVEC_LIEN DATE_COURBE,
  crb.TYPE_COURBE      TYPE_COURBE,
      crb.PARENT_ID, crb.COMPLETUDE_ID
from dates_avec_lien
left join DIA_COMPLETUDE_COURBE_ARENH crb on JOUR_AVEC_LIEN = crb.DATE_COURBE
  and
--     crb.PARENT_ID = 11416
    crb.PARENT_ID = 11579
    AND crb.TYPE_COURBE IN (69,70,71,72,73)
    AND crb.STATUT = 2
order by DATE_COURBE, PARENT_ID, TYPE_COURBE
;


