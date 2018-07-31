ALTER TABLE core.users ADD COLUMN role_type BIGINT;

CREATE TABLE core.user_roles (
  id         BIGINT NOT NULL DEFAULT sp.global_seq_val('core.user_roles'),
  external_id TEXT NOT NULL,
  nam         TEXT NOT NULL,
  comments    TEXT,
  created TIMESTAMP NOT NULL DEFAULT current_timestamp,
  updated TIMESTAMP NOT NULL DEFAULT current_timestamp,
  PRIMARY KEY (id)
);

ALTER TABLE core.user_roles ADD CONSTRAINT user_roles_external_id_uniq UNIQUE (external_id);
ALTER TABLE core.user_roles ADD CONSTRAINT user_roles_nam_uniq UNIQUE (nam);

CREATE FUNCTION sp.user_roles (_id BIGINT, _external_id TEXT, _nam TEXT, _comments TEXT) RETURNS TEXT AS $$
DECLARE
  _row RECORD;
  _new_id BIGINT;
BEGIN
  SELECT INTO _row * FROM core.user_roles WHERE id = _id;
  IF FOUND THEN
    IF ROW(_row.external_id, _row.nam, _row.comments) is distinct from ROW(_external_id , _nam, _comments) Then
      update core.user_roles set external_id = _external_id, nam = _name, comments = _comments, updated = current_timestamp where id = _id;
      return 'updated';
    ELSE
      return 'unchanged';
    end if;
  else
    insert into core.user_roles (external_id, nam, comments) values (_external_id, _nam, _comments) returning id into _new_id;
    return _new_id::text;
  end if;
end;
$$ language plpgsql;

select sp.user_roles(null, '1', 'Admin', 'has all the previllages. can act like mechanic , clerk or extra');
select sp.user_roles(null, '2', 'Mechanic', 'can only act as individual mechanic');
select sp.user_roles(null, '3', 'Clerk', 'can only act as front desk');


