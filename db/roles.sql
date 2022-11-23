    DO $$
    BEGIN
        PERFORM true FROM pg_roles WHERE rolname = 'app_anon';
        IF NOT FOUND THEN
          CREATE ROLE app_anon;
        END IF;
    END;
    $$;

    DO $$
    BEGIN
        PERFORM true FROM pg_roles WHERE rolname = 'app_usr';
        IF NOT FOUND THEN
          CREATE ROLE app_usr;
            GRANT app_anon TO app_usr;
        END IF;
    END;
    $$;

    DO $$
    BEGIN
        PERFORM true FROM pg_roles WHERE rolname = 'app_auth';
        IF NOT FOUND THEN
            CREATE ROLE app_auth with noinherit login;
            GRANT app_anon TO app_auth;
            GRANT app_usr TO app_auth;
            ALTER ROLE app_auth with password '1234';
        END IF;
    END;
    $$;
