CREATE OR REPLACE FUNCTION auto_grant_func ()
    RETURNS event_trigger
    AS $$
BEGIN
    GRANT ALL ON ALL tables IN SCHEMA public TO data;
    GRANT ALL ON ALL sequences IN SCHEMA public TO data;
    GRANT SELECT ON ALL tables IN SCHEMA public TO readonly;
    GRANT SELECT ON ALL sequences IN SCHEMA public TO readonly;
    GRANT ALL ON ALL tables IN SCHEMA public TO apps;
    GRANT ALL ON ALL sequences IN SCHEMA public TO apps;
    GRANT SELECT, INSERT, UPDATE ON ALL tables IN SCHEMA public TO engineers;
    GRANT ALL ON ALL sequences IN SCHEMA public TO engineers;
END;
$$
LANGUAGE plpgsql;

CREATE EVENT TRIGGER auto_grant_trigger ON ddl_command_end
    WHEN TAG IN ('CREATE TABLE', 'CREATE TABLE AS')
        EXECUTE PROCEDURE auto_grant_func ();

-- For each database
GRANT ALL ON ALL tables IN SCHEMA public TO data;

GRANT ALL ON ALL sequences IN SCHEMA public TO data;

GRANT SELECT ON ALL tables IN SCHEMA public TO readonly;

GRANT SELECT ON ALL sequences IN SCHEMA public TO readonly;

GRANT ALL ON ALL tables IN SCHEMA public TO apps;

GRANT ALL ON ALL sequences IN SCHEMA public TO apps;

GRANT SELECT, INSERT, UPDATE ON ALL tables IN SCHEMA public TO engineers;

GRANT ALL ON ALL sequences IN SCHEMA public TO engineers;

GRANT USAGE ON SCHEMA public TO apps, engineers, data, readonly;

DO $$
DECLARE
    item RECORD;
    new_owner varchar := 'migration';
BEGIN
    FOR item IN
    SELECT
        tablename
    FROM
        pg_tables
    WHERE
        schemaname = 'public' LOOP
            EXECUTE format('ALTER TABLE %I OWNER TO %I', item.tablename, new_owner);
        END LOOP;
    FOR item IN
    SELECT
        tablename
    FROM
        pg_tables
    WHERE
        schemaname = 'public' LOOP
            EXECUTE format('ALTER TABLE %I OWNER TO %I', item.tablename, new_owner);
        END LOOP;
    FOR item IN
    SELECT
        t.typname
    FROM
        pg_type t
        JOIN pg_user u ON t.typowner = u.usesysid
        JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
    WHERE
        n.nspname = 'public'
        AND t.oid IN ( SELECT DISTINCT
                enumtypid
            FROM
                pg_enum)
            LOOP
                EXECUTE format('ALTER TYPE %I OWNER TO %I', item.typname, new_owner);
            END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION change_table_owner ()
    RETURNS event_trigger
    AS $$
DECLARE
    item RECORD;
    new_owner varchar := 'migration';
BEGIN
    FOR item IN
    SELECT
        tablename
    FROM
        pg_tables
    WHERE
        schemaname = 'public'
        AND tableowner = CURRENT_USER LOOP
            EXECUTE format('ALTER TABLE %I OWNER TO %I', item.tablename, new_owner);
        END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE EVENT TRIGGER change_table_owner_trigger ON ddl_command_end
    WHEN TAG IN ('CREATE TABLE', 'CREATE TABLE AS')
        EXECUTE FUNCTION change_table_owner ();

CREATE OR REPLACE FUNCTION change_sequence_owner ()
    RETURNS event_trigger
    AS $$
DECLARE
    item RECORD;
    new_owner varchar := 'migration';
BEGIN
    FOR item IN
    SELECT
        sequencename
    FROM
        pg_sequences
    WHERE
        schemaname = 'public'
        AND sequenceowner = CURRENT_USER LOOP
            EXECUTE format('ALTER SEQUENCE %I OWNER TO %I', item.sequencename, new_owner);
        END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE EVENT TRIGGER change_sequence_owner_trigger ON ddl_command_end
    WHEN TAG IN ('CREATE SEQUENCE')
        EXECUTE FUNCTION change_sequence_owner ();

CREATE OR REPLACE FUNCTION change_enum_owner ()
    RETURNS event_trigger
    AS $$
DECLARE
    item RECORD;
    new_owner varchar := 'migration';
BEGIN
    FOR item IN
    SELECT
        t.typname
    FROM
        pg_type t
        JOIN pg_user u ON t.typowner = u.usesysid
        JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
    WHERE
        n.nspname = 'public'
        AND u.usename = CURRENT_USER
        AND t.oid IN ( SELECT DISTINCT
                enumtypid
            FROM
                pg_enum)
            LOOP
                EXECUTE format('ALTER TYPE %I OWNER TO %I', item.typname, new_owner);
            END LOOP;
END;
$$
LANGUAGE plpgsql;

CREATE EVENT TRIGGER change_enum_owner_trigger ON ddl_command_end
    WHEN TAG IN ('CREATE TYPE')
        EXECUTE FUNCTION change_enum_owner ();
