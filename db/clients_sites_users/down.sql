DROP FUNCTION sp.activate_user(_id BIGINT);
DROP FUNCTION sp.deactivate_user(_id BIGINT);
DROP FUNCTION sp.change_user_password(_id BIGINT, _current_password TEXT, _new_password TEXT, _confirm_new_password TEXT);
DROP FUNCTION sp.login(_external_id TEXT, _password TEXT);
DROP FUNCTION sp.register_user(
  _external_id      TEXT,
  _client_id        BIGINT,
  _name             TEXT,
  _password         TEXT,
  _confirm_password TEXT
);
DROP FUNCTION sp.update_user(_id BIGINT, _external_id TEXT, _name TEXT);

DROP EXTENSION pgcrypto;

DROP TABLE core.users;

DROP FUNCTION sp.sites( _id BIGINT, _client_id BIGINT, _external_id TEXT, _name TEXT );
DROP TABLE core.sites;

DROP FUNCTION sp.clients( _id BIGINT, _external_id TEXT, _name TEXT );
DROP TABLE core.clients;
