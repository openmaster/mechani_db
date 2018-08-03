DROP FUNCTION sp.login(_user_name TEXT, _password TEXT);

CREATE FUNCTION sp.login(_user_name TEXT, _password TEXT) RETURNS text AS $$
DECLARE
  _row RECORD;
BEGIN
  SELECT INTO _row * FROM core.users WHERE user_name = _user_name;
  IF FOUND THEN
    IF crypt(_password, _row.password) = _row.password THEN
      RETURN _row.id::text;
    ELSE
      RETURN 'invalid password';
    END IF;
  ELSE
    RETURN 'user not found';
  END IF;
END;
$$ LANGUAGE plpgsql;

