DROP FUNCTION sp.job_parts(
   _client_id             BIGINT,
   _site_id               BIGINT,
   _job_id                BIGINT,
   _part_id               BIGINT,
   _quantity              SMALLINT,
   _sale_price            NUMERIC(10,2),
   _cost_price            NUMERIC(10,2)
);

DROP TABLE core.job_parts;
