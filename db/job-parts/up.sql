CREATE TABLE core.job_parts (
  client_id           BIGINT NOT NULL REFERENCES core.clients(id),
  site_id             BIGINT NOT NULL REFERENCES core.sites(id),
  job_id              BIGINT NOT NULL REFERENCES core.jobs(id),
  part_id             BIGINT NOT NULL REFERENCES pb.parts(id),
  quantity            SMALLINT NOT NULL,
  sale_price          NUMERIC(10,2),
  cost_price          NUMERIC(10,2),
  created             TIMESTAMP NOT NULL DEFAULT current_timestamp,
  updated             TIMESTAMP NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (client_id, site_id, job_id, part_id)
);
 ALTER TABLE core.job_parts ADD CONSTRAINT client_site_job_id_part_id UNIQUE(client_id, site_id, job_id, part_id);

 CREATE FUNCTION sp.job_parts(
   _client_id             BIGINT,
   _site_id               BIGINT,
   _job_id                BIGINT,
   _part_id               BIGINT,
   _quantity              SMALLINT,
   _sale_price            NUMERIC(10,2),
   _cost_price            NUMERIC(10,2)
 ) RETURNS TEXT AS $$
 DECLARE
  _row RECORD;
  _new_id BIGINT;
BEGIN
  SELECT INTO _row * FROM core.job_parts WHERE client_id = _client_id and site_id = _site_id and job_id = _job_id and part_id = _part_id;
  IF FOUND THEN
    IF ROW(
      _row.part_id,
      _row.quantity,
      _row.sale_price,
      _row.cost_price
    ) IS DISTINCT FROM (
      _part_id,
      _quantity,
      _sale_price,
      _cost_price
    ) THEN
      UPDATE core.job_parts SET
      part_id    =   _part_id,
      quantity   =   _quantity,
      sale_price =   _sale_price,
      cost_price =   _sale_price

      WHERE client_id = _client_id and site_id = _site_id and job_id = _job_id and part_id = _part_id;
      RETURN 'updated';
    ELSE
      RETURN 'unchanged';
    END IF;
  ELSE
    INSERT INTO core.job_parts (
      client_id,
      site_id,
      Job_id,
      part_id,
      quantity,
      sale_price,
      cost_price
    ) VALUES (
      _client_id,
      _site_id,
      _job_id,
      _part_id,
      _quantity,
      _sale_price,
      _cost_price
    );
    RETURN 'added';
  END IF;
END;
$$LANGUAGE plpgsql;

