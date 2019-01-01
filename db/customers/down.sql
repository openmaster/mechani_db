DROP FUNCTION sp.customers(
  _id            BIGINT,
  _client_id     BIGINT,
  _site_id       BIGINT,
  _first_name    TEXT,
  _last_name     TEXT,
  _phone          INTEGER,
  _email          TEXT,
  _address1       TEXT,
  _address2       TEXT,
  _city           TEXT,
  _state          TEXT,
  _zip            TEXT
);

DROP TABLE loyalty.customers;

DROP SCHEMA loyalty;
