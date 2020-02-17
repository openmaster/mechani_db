DROP FUNCTION sp.job_parts(
   _client_id             BIGINT,
   _site_id               BIGINT,
   _job_id                BIGINT,
   _part_id               BIGINT,
   _quantity              SMALLINT
);

DROP TABLE core.job_parts;
