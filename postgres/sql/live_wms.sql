CREATE MATERIALIZED VIEW live.v_nutzungsplanung_grundnutzung AS 

WITH RECURSIVE x(ursprung, hinweis, parents, last_ursprung, depth) AS 
(
    SELECT 
        ursprung, 
        hinweis, 
        ARRAY[ursprung] AS parents, 
        ursprung AS last_ursprung, 
        0 AS "depth" 
    FROM 
        live.oerbkrmvs_v1_1vorschriften_hinweisweiteredokumente
    WHERE
        ursprung != hinweis

    UNION ALL
  
    SELECT 
        x.ursprung, 
        x.hinweis, 
        parents||t1.hinweis, 
        t1.hinweis AS last_ursprung, 
        x."depth" + 1
    FROM 
        x 
        INNER JOIN live.oerbkrmvs_v1_1vorschriften_hinweisweiteredokumente t1 
        ON (last_ursprung = t1.ursprung)
    WHERE 
        t1.hinweis IS NOT NULL
)
,
flattened_documents AS 
(
    SELECT 
        DISTINCT ON (x.last_ursprung, x.ursprung)
        x.ursprung AS top_level_dokument,
        x.last_ursprung AS t_id,
        dokument.t_ili_tid AS t_ili_tid,  
        dokument.t_type AS t_type,
        dokument.titel AS titel,
        dokument.offiziellertitel AS offiziellertitel,
        dokument.abkuerzung AS abkuerzung,
        dokument.offiziellenr AS offiziellenr,
        dokument.kanton AS kanton,
        dokument.gemeinde AS gemeinde,
        dokument.rechtsstatus AS rechtsstatus,
        dokument.publiziertab AS publiziertab,
        url.textimweb AS textimweb
    FROM 
        x
        LEFT JOIN live.oerbkrmvs_v1_1vorschriften_dokument AS dokument
        ON dokument.t_id = x.last_ursprung
        LEFT JOIN 
        (
            SELECT
                atext AS textimweb,
                oerbkrmvs_vrftn_dkment_textimweb AS dokument_t_id
                
            FROM
                live.oerebkrm_v1_1_localiseduri AS localiseduri
                LEFT JOIN live.oerebkrm_v1_1_multilingualuri AS multilingualuri
                ON localiseduri.oerbkrm_v1__mltlngluri_localisedtext = multilingualuri.t_id
            WHERE
                localiseduri.alanguage = 'de'
        ) AS url
        ON url.dokument_t_id = dokument.t_id
    WHERE
        last_ursprung NOT IN
        (
            SELECT 
                DISTINCT ON (eigentumsbeschraenkung.t_id)
                eigentumsbeschraenkung.t_id
            FROM
                live.oerbkrmfr_v1_1transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
                RIGHT JOIN live.oerbkrmfr_v1_1transferstruktur_hinweisvorschrift AS hinweisvorschrift
                ON eigentumsbeschraenkung.t_id = hinweisvorschrift.eigentumsbeschraenkung
        )
)
,
-- remove duplicate documents with distinct first, then group them.
json_documents AS 
(
    SELECT
        DISTINCT ON (eigentumsbeschraenkung, flattened_documents.t_id)
        hinweisvorschrift.eigentumsbeschraenkung,
        json_strip_nulls(row_to_json(flattened_documents)) AS dokumente
        
    FROM  
        flattened_documents
        LEFT JOIN live.oerbkrmfr_v1_1transferstruktur_hinweisvorschrift AS hinweisvorschrift
        ON hinweisvorschrift.vorschrift_oerbkrmvs_v1_1vorschriften_dokument = flattened_documents.top_level_dokument
    WHERE
        eigentumsbeschraenkung IS NOT NULL
)
,
grouped_json_documents AS
(
    SELECT
        eigentumsbeschraenkung,
        json_agg(dokumente) AS dokumente
    FROM
        json_documents
    GROUP BY
        eigentumsbeschraenkung
)
SELECT
    geometrie.t_id AS t_id,
    geometrie.flaeche_lv95 AS geometrie,
    geometrie.rechtsstatus AS geometrie_rechtsstatus,
    geometrie.publiziertab AS geometrie_publiziertab,
    eigentumsbeschraenkung.thema,
    eigentumsbeschraenkung.subthema,
    eigentumsbeschraenkung.artcode,
    eigentumsbeschraenkung.aussage_de,
    eigentumsbeschraenkung.rechtsstatus,
    eigentumsbeschraenkung.publiziertab,
    grouped_json_documents.dokumente AS dokumente
FROM
    live.oerbkrmfr_v1_1transferstruktur_geometrie AS geometrie
    LEFT JOIN live.oerbkrmfr_v1_1transferstruktur_eigentumsbeschraenkung AS eigentumsbeschraenkung
    ON eigentumsbeschraenkung.t_id = geometrie.eigentumsbeschraenkung
    LEFT JOIN grouped_json_documents
    ON grouped_json_documents.eigentumsbeschraenkung = eigentumsbeschraenkung.t_id
WHERE
    eigentumsbeschraenkung.thema = 'Nutzungsplanung'
    AND
    eigentumsbeschraenkung.subthema = 'Grundnutzung_Zonenflaeche'
    AND
    geometrie.flaeche_lv95 IS NOT NULL
;

