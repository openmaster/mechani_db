CREATE TABLE pb.parts (
  id                  BIGINT NOT NULL DEFAULT sp.global_seq_val('pb.parts'),
  external_id         BIGINT NOT NULL,
  client_id           BIGINT NOT NULL REFERENCES core.clients(id),
  site_id             BIGINT NOT NULL REFERENCES core.sites(id),
  department_id       BIGINT NOT NULL REFERENCES pb.departments(id),
  name                TEXT NOT NULL,
  description         TEXT,
  bar_code            TEXT,
  created             TIMESTAMP NOT NULL DEFAULT current_timestamp,
  updated             TIMESTAMP NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (id)
);
 ALTER TABLE pb.parts ADD CONSTRAINT parts_client_site_external_id UNIQUE(client_id, site_id, external_id);

 CREATE FUNCTION sp.parts(
   _id                    BIGINT,
   _external_id           BIGINT,
   _client_id             BIGINT,
   _site_id               BIGINT,
   _department_id         BIGINT,
   _name                  TEXT,
   _description           TEXT,
   _bar_code              TEXT
 ) RETURNS TEXT AS $$
 DECLARE
  _row RECORD;
  _new_id BIGINT;
BEGIN
  SELECT INTO _row * FROM pb.parts WHERE id = _id;
  IF FOUND THEN
    IF ROW(
      _row.external_id,
      _row.department_id,
      _row.name,
      _row.description,
      _row.bar_code
    ) IS DISTINCT FROM (
      _external_id,
      _department_id,
      _name,
      _description,
      _bar_code
    ) THEN
      UPDATE pb.parts SET
      external_id     =   _external_id,
      department_id   =   _department_id,
      name            =   _name,
      description     =   _description,
      bar_code        =   _bar_code,
      updated         =   current_timestamp
        WHERE id = _id;
      RETURN 'updated';
    ELSE
      RETURN 'unchanged';
    END IF;
  ELSE
    INSERT INTO loyalty.customers (
      external_id,
      client_id,
      site_id,
      department_id,
      name,
      description,
      bar_code
    ) VALUES (
      _external_id,
      _client_id,
      _site_id,
      _department_id,
      _name,
      _description,
      _bar_code
    ) RETURNING id INTO _new_id;
    RETURN _new_id::TEXT;
  END IF;
END;
$$LANGUAGE plpgsql;
