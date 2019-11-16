CREATE FUNCTION sp.login_jwt(_user_name TEXT, _password TEXT) RETURNS TEXT AS $$
DECLARE
  _row RECORD;
BEGIN
  SELECT INTO _row * FROM core.users WHERE user_name = _user_name;
  IF FOUND THEN
    IF crypt(_password, _row.password) = _row.password  AND _row.active = 't' THEN
      RETURN _row.id::TEXT;
    ELSE
      RETURN 'invalid';
    END IF;
  ELSE
    RETURN 'invalid';
  END IF;
END;
$$ LANGUAGE plpgsql;

