DROP FUNCTION sp.parts(
  _id            BIGINT,
  _external_id   BIGINT,
  _client_id     BIGINT,
  _site_id       BIGINT,
  _department_id BIGINT,
  _name          TEXT,
  _description   TEXT,
  _bar_code      TEXT
);

DROP TABLE pb.parts;
