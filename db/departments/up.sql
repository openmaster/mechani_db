CREATE SCHEMA pb;
CREATE TABLE pb.departments (
  id           BIGINT NOT NULL DEFAULT sp.global_seq_val('pb.departments'),
  external_id  BIGINT NOT NULL,
  client_id    BIGINT NOT NULL REFERENCES core.clients(id),
  site_id      BIGINT NOT NULL REFERENCES core.sites(id),
  name         TEXT NOT NULL,
  description  TEXT,
  created      TIMESTAMP NOT NULL DEFAULT current_timestamp,
  updated      TIMESTAMP NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (id)
);
 ALTER TABLE pb.departments ADD CONSTRAINT client_site_external_id UNIQUE(client_id, site_id, external_id);

 CREATE FUNCTION sp.departments(
   _id            BIGINT,
   _external_id   BIGINT,
   _client_id     BIGINT,
   _site_id       BIGINT,
   _name          TEXT,
   _description   TEXT
 ) RETURNS TEXT AS $$
 DECLARE
  _row RECORD;
  _new_id BIGINT;
BEGIN
  SELECT INTO _row * FROM pb.departments WHERE id = _id;
  IF FOUND THEN
    IF ROW(
      _row.external_id,
      _row.name,
      _row.description
    ) IS DISTINCT FROM (
      _external_id,
      _name,
      _description
    ) THEN
      UPDATE pb.departments SET
      external_id = _external_id,
      name = _name,
      description  = _description,
      updated     = current_timestamp
      WHERE id = _id;
      RETURN 'updated';
    ELSE
      RETURN 'unchanged';
    END IF;
  ELSE
    INSERT INTO pb.departments (
      external_id,
      client_id,
      site_id,
      name,
      description
    ) VALUES (
      _external_id,
      _client_id,
      _site_id,
      _name,
      _description
    ) RETURNING id INTO _new_id;
    RETURN _new_id::TEXT;
  END IF;
END;
$$LANGUAGE plpgsql;
