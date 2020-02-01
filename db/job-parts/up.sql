CREATE TABLE core.job_parts (
  id                  BIGINT NOT NULL DEFAULT sp.global_seq_val('core.job-parts'),
  client_id           BIGINT NOT NULL REFERENCES core.clients(id),
  site_id             BIGINT NOT NULL REFERENCES core.sites(id),
  job_id              BIGINT NOT NULL REFERENCES core.jobs(id),
  part_id             BIGINT NOT NULL REFERENCES pb.parts(id),
  quantity            SMALLINT NOT NULL,
  created             TIMESTAMP NOT NULL DEFAULT current_timestamp,
  updated             TIMESTAMP NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (id)
);
 ALTER TABLE core.job_parts ADD CONSTRAINT client_site_job_id_part_id UNIQUE(client_id, site_id, job_id, part_id);

 CREATE FUNCTION sp.job_parts(
   _id                    BIGINT,
   _client_id             BIGINT,
   _site_id               BIGINT,
   _job_id                BIGINT,
   _part_id               BIGINT,
   _quantity              SMALLINT
 ) RETURNS TEXT AS $$
 DECLARE
  _row RECORD;
  _new_id BIGINT;
BEGIN
  SELECT INTO _row * FROM core.job_parts WHERE id = _id;
  IF FOUND THEN
    IF ROW(
      _row.job_id,
      _row.part_id,
      _row.quantity
    ) IS DISTINCT FROM (
      _job_id,
      _part_id,
      _quantity
    ) THEN
      UPDATE core.job_parts SET
      job_id     =   _job_id,
      part_id    =   _part_id,
      quantity   =   _quantity
        WHERE id = _id;
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
      quantity
    ) VALUES (
      _client_id,
      _site_id,
      _job_id,
      _part_id,
      _quantity
    ) RETURNING id INTO _new_id;
    RETURN _new_id::TEXT;
  END IF;
END;
$$LANGUAGE plpgsql;

