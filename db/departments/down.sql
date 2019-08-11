DROP FUNCTION sp.departments(
  _id            BIGINT,
  _external_id   BIGINT,
  _client_id     BIGINT,
  _site_id       BIGINT,
  _name          TEXT,
  _description   TEXT
);

DROP TABLE pb.departments;

DROP SCHEMA pb;
