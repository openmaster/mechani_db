CREATE TABLE core.jobs (
  id         BIGINT NOT NULL DEFAULT sp.global_seq_val('core.jobs'),
  client_id  BIGINT NOT NULL REFERENCES core.clients(id),
  site_id    BIGINT NOT NULL REFERENCES core.sites(id),
  createdBy  BIGINT NOT NULL REFERENCES core.users(id),
  customer_id BIGINT NOT NULL REFERENCES loyalty.customers(id),
  invoice    TEXT NOT NULL,
  nam        TEXT NULL NULL,
  comments   TEXT,
  vehicle_detail TEXT,
  created TIMESTAMP NOT NULL DEFAULT current_timestamp,
  updated TIMESTAMP NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (id)
);

ALTER TABLE core.jobs ADD CONSTRAINT client_site_invoice UNIQUE (client_id, site_id, invoice);

CREATE FUNCTION sp.jobs (_id BIGINT, _client_id BIGINT, _site_id BIGINT, _createdBy BIGINT, _customer_id BIGINT, _invoice TEXT, _nam TEXT, _comments TEXT, _vehicle_detail TEXT) RETURNS TEXT AS $$
DECLARE
  _row RECORD;
  _new_id BIGINT;
BEGIN
  SELECT INTO _row * FROM core.jobs WHERE id = _id;
  IF FOUND THEN
    IF ROW(_row.invoice, _row.nam, _row.comments, _row.customer_id, _row.vehicle_detail) IS DISTINCT FROM (_invoice, _nam, _comments, _customer_id, _vehicle_detail)THEN
      UPDATE core.jobs SET invoice = _invoice, nam = _nam, comments = _comments, customer_id = _customer_id, vehicle_detail = _vehicle_detail, updated = current_timestamp WHERE id = _id;
      RETURN 'updated';
    ELSE
      RETURN 'unchanged';
    END IF;
  ELSE
    INSERT INTO core.jobs (client_id, site_id, createdBy, invoice, nam, comments, customer_id, vehicle_detail) VALUES (_client_id, _site_id, _createdBy, _invoice, _nam, _comments, _customer_id, _vehicle_detail) RETURNING id INTO _new_id;
    RETURN _new_id::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql;
