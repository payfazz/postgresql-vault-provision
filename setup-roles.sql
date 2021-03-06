CREATE ROLE data;

CREATE ROLE readonly;

CREATE ROLE apps;

CREATE ROLE engineers;

CREATE ROLE exporter;

CREATE ROLE v_admin WITH CREATEROLE CREATEDB INHERIT LOGIN;

CREATE ROLE vault_postgres WITH CREATEROLE LOGIN;

CREATE ROLE migration;

GRANT migration TO vault_postgres, v_admin, apps, engineers, flazz;

GRANT rds_superuser to v_admin, vault_postgres, exporter;

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;