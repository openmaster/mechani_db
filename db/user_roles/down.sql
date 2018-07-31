ALTER TABLE core.users DROP COLUMN role_type;

drop function sp.user_roles(_id BIGINT, _external_id TEXT, _nam TEXT, _comments TEXT);
drop table core.user_roles;
