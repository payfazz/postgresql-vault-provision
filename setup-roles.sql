CREATE ROLE data;

CREATE ROLE readonly;

CREATE ROLE apps;

CREATE ROLE engineers;

CREATE ROLE v_admin superuser LOGIN;

CREATE ROLE vault_postgres superuser LOGIN;

CREATE ROLE migration;

GRANT migration TO postgres, v_admin, apps, engineers;
