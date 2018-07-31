CREATE SCHEMA core;
CREATE SCHEMA sp;

CREATE SEQUENCE core.global_seq START 1000;

CREATE TABLE core.global_objects (
  id          BIGINT    NOT NULL PRIMARY KEY,
  object_type TEXT      NOT NULL,
  created     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE core.global_objects ADD CONSTRAINT id_object_type_unq UNIQUE(id, object_type);

CREATE FUNCTION sp.global_seq_val(_type TEXT) RETURNS BIGINT AS $$
DECLARE
  _id BIGINT;
BEGIN
  _id := nextval('core.global_seq');
  INSERT INTO core.global_objects(id, object_type) VALUES (_id, _type);
  RETURN _id;
END;
$$ LANGUAGE plpgsql;
