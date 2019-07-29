CREATE SCHEMA loyalty;
CREATE TABLE loyalty.customers (
  id           BIGINT NOT NULL DEFAULT sp.global_seq_val('loyalty.customers'),
  external_id  BIGINT NOT NULL,
  client_id    BIGINT NOT NULL REFERENCES core.clients(id),
  site_id      BIGINT NOT NULL REFERENCES core.sites(id),
  first_name   TEXT NOT NULL,
  last_name    TEXT,
  phone        TEXT,
  email        TEXT,
  address1     TEXT,
  address2     TEXT,
  city         TEXT,
  state        TEXT,
  zip          TEXT,
  created      TIMESTAMP NOT NULL DEFAULT current_timestamp,
  updated      TIMESTAMP NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (id)
);
 ALTER TABLE loyalty.customers ADD CONSTRAINT client_site_first_name UNIQUE(client_id, site_id, external_id);

 CREATE FUNCTION sp.customers(
   _id            BIGINT,
   _external_id   BIGINT,
   _client_id     BIGINT,
   _site_id       BIGINT,
   _first_name    TEXT,
   _last_name     TEXT,
   _phone         TEXT,
   _email         TEXT,
   _address1      TEXT,
   _address2      TEXT,
   _city          TEXT,
   _state         TEXT,
   _zip           TEXT
 ) RETURNS TEXT AS $$
 DECLARE
  _row RECORD;
  _new_id BIGINT;
BEGIN
  SELECT INTO _row * FROM loyalty.customers WHERE id = _id;
  IF FOUND THEN
    IF ROW(
      _row.external_id,
      _row.first_name,
      _row.last_name,
      _row.phone,
      _row.email,
      _row.address1,
      _row.address2,
      _row.city,
      _row.state,
      _row.zip
    ) IS DISTINCT FROM (
      _external_id,
      _first_name,
      _last_name,
      _phone,
      _email,
      _address1,
      _address2,
      _city,
      _state,
      _zip
    ) THEN
      UPDATE loyalty.customers SET
      external_id = _external_id,
      first_name = _first_name,
      last_name  = _last_name,
      phone      = _phone,
      email      = _email,
      address1   = _address1,
      address2   = _address2,
      city       = _city,
      state      = _state,
      zip        = _zip,
      updated     = current_timestamp
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
      first_name,
      last_name,
      phone,
      email,
      address1,
      address2,
      city,
      state,
      zip
    ) VALUES (
      _external_id,
      _client_id,
      _site_id,
      _first_name,
      _last_name,
      _phone,
      _email,
      _address1,
      _address2,
      _city,
      _state,
      _zip
    ) RETURNING id INTO _new_id;
    RETURN _new_id::TEXT;
  END IF;
END;
$$LANGUAGE plpgsql;
