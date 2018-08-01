CREATE TABLE core.clients (
  id BIGINT NOT NULL DEFAULT sp.global_seq_val('core.clients'),
  external_id TEXT NOT NULL,
  name TEXT NOT NULL,
  created TIMESTAMP NOT NULL DEFAULT current_timestamp,
  updated TIMESTAMP NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (id)
);

ALTER TABLE core.clients ADD CONSTRAINT clients_external_id_uniq UNIQUE (external_id);
ALTER TABLE core.clients ADD CONSTRAINT clients_name_uniq UNIQUE (name);

CREATE FUNCTION sp.clients( _id BIGINT, _external_id TEXT, _name TEXT ) RETURNS text AS $$
DECLARE
  _row RECORD;
  _new_id BIGINT;
BEGIN
  SELECT INTO _row * FROM core.clients WHERE id = _id;
  IF FOUND THEN
    IF ROW( _row.external_id, _row.name ) IS DISTINCT FROM
       ROW( _external_id, _name ) THEN
      UPDATE core.clients SET id = _id, external_id = _external_id, name = _name, updated = current_timestamp
      WHERE id = _id;
      RETURN 'updated';
    ELSE
      RETURN 'unchanged';
    END IF;
  ELSE
    INSERT INTO core.clients ( external_id, name ) VALUES ( _external_id, _name ) RETURNING id INTO _new_id;
    RETURN _new_id::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE core.sites (
  id BIGINT NOT NULL DEFAULT sp.global_seq_val('core.sites'),
  client_id BIGINT NOT NULL REFERENCES core.clients(id),
  external_id TEXT NOT NULL,
  name TEXT NOT NULL,
  created TIMESTAMP NOT NULL DEFAULT current_timestamp,
  updated TIMESTAMP NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (id)
);

CREATE FUNCTION sp.sites( _id BIGINT, _client_id BIGINT, _external_id TEXT, _name TEXT ) RETURNS text AS $$
DECLARE
  _row RECORD;
  _new_id BIGINT;
BEGIN
  SELECT INTO _row * FROM core.sites WHERE id = _id;
  IF FOUND THEN
    IF ROW( _row.client_id, _row.external_id, _row.name ) IS DISTINCT FROM
       ROW( _client_id, _external_id, _name ) THEN
      UPDATE core.sites SET id = _id, client_id = _client_id, external_id = _external_id, name = _name, updated = current_timestamp
      WHERE id = _id;
      RETURN 'updated';
    ELSE
      RETURN 'unchanged';
    END IF;
  ELSE
    INSERT INTO core.sites ( client_id, external_id, name ) VALUES
    ( _client_id, _external_id, _name ) RETURNING id INTO _new_id;
    RETURN _new_id::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql;

ALTER TABLE core.sites ADD CONSTRAINT sites_client_id_external_id_uniq UNIQUE (client_id, external_id);
ALTER TABLE core.sites ADD CONSTRAINT sites_client_id_name_uniq UNIQUE (client_id, name);

CREATE TABLE core.users (
  id BIGINT NOT NULL DEFAULT sp.global_seq_val('core.users'),
  user_name TEXT NOT NULL,
  client_id BIGINT NOT NULL REFERENCES core.clients(id),
  site_id BIGINT NOT NULL REFERENCES core.sites(id),
  name TEXT NOT NULL,
  password TEXT NOT NULL,
  password_updated TIMESTAMP NOT NULL,
  active BOOLEAN NOT NULL DEFAULT 't',
  roles BIGINT NOT NULL REFERENCES core.user_roles(id),
  created TIMESTAMP NOT NULL DEFAULT current_timestamp,
  updated TIMESTAMP NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (id)
);

ALTER TABLE core.users ADD CONSTRAINT users_user_name_uniq UNIQUE (user_name);
ALTER TABLE core.users ADD CONSTRAINT users_client_id_site_id_name_uniq UNIQUE (client_id, site_id, name);

CREATE EXTENSION pgcrypto;

CREATE FUNCTION sp.update_user(_id BIGINT, _user_name TEXT, _name TEXT, _roles BIGINT) RETURNS text AS $$
DECLARE
  _row RECORD;
BEGIN
  SELECT INTO _row * FROM core.users WHERE id = _id;
  IF FOUND THEN
    IF ROW(_row.user_name, _row.name, _row.roles) IS DISTINCT FROM ROW(_user_name, _name, _roles) THEN
      UPDATE core.users SET name = _name, user_name = _user_name, roles = _roles WHERE id  = _id;
      RETURN 'updated';
    ELSE
      RETURN 'unchanged';
    END IF;
  ELSE
    RETURN 'not found';
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sp.register_user(
  _user_name      TEXT,
  _client_id        BIGINT,
  _site_id          BIGINT,
  _name             TEXT,
  _password         TEXT,
  _confirm_password TEXT,
  _roles            BIGINT
) RETURNS TEXT AS $$
DECLARE
  _id BIGINT;
BEGIN
  IF _password <> _confirm_password THEN
    RETURN 'invalid confirmation';
  END IF;

  PERFORM 1 FROM core.users WHERE id = _id;
  IF NOT FOUND THEN
    INSERT INTO core.users ( user_name, client_id, site_id, name, password, password_updated, roles ) VALUES
    ( _user_name, _client_id, _site_id, _name, crypt(_password, gen_salt('md5')), CURRENT_TIMESTAMP, _roles ) RETURNING id INTO _id;
    RETURN _id::TEXT;
  ELSE
    RETURN 'already exists';
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sp.login(_user_name TEXT, _password TEXT) RETURNS text AS $$
DECLARE
  _row RECORD;
BEGIN
  SELECT INTO _row * FROM core.users WHERE user_name = _user_name;
  IF FOUND THEN
    IF crypt(_password, _row.password) = _row.password THEN
      RETURN 'ok';
    ELSE
      RETURN 'invalid password';
    END IF;
  ELSE
    RETURN 'user not found';
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sp.change_user_password(_id BIGINT, _current_password TEXT, _new_password TEXT, _confirm_new_password TEXT) RETURNS text AS $$
DECLARE
  _row RECORD;
BEGIN
  IF _new_password <> _confirm_new_password THEN
    RETURN 'invalid confirmation';
  END IF;

  SELECT INTO _row * FROM core.users WHERE id = _id;
  IF FOUND THEN
    IF crypt(_current_password, _row.password) = _row.password THEN
      UPDATE core.users SET password = crypt(_new_password, gen_salt('md5')), password_updated = CURRENT_TIMESTAMP WHERE id = _id;
      RETURN 'updated';
    ELSE
      RETURN 'invalid password';
    END IF;
  ELSE
    RETURN 'not found';
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sp.deactivate_user(_id BIGINT) RETURNS boolean AS $$
DECLARE
  _row RECORD;
BEGIN
  SELECT INTO _row * FROM core.users WHERE id = _id;
  IF FOUND THEN
    IF _row.active THEN
      UPDATE core.users SET active = 'f', updated = CURRENT_TIMESTAMP WHERE id = _id;
      RETURN 't';
    ELSE
      RETURN 'f';
    END IF;
  ELSE
    RETURN 't';
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sp.activate_user(_id BIGINT) RETURNS boolean AS $$
DECLARE
  _row RECORD;
BEGIN
  SELECT INTO _row * FROM core.users WHERE id = _id;
  IF FOUND THEN
    IF NOT _row.active THEN
      UPDATE core.users SET active = 't', updated = CURRENT_TIMESTAMP WHERE id = _id;
      RETURN 't';
    ELSE
      RETURN 'f';
    END IF;
  ELSE
    RETURN 't';
  END IF;
END;
$$ LANGUAGE plpgsql;
