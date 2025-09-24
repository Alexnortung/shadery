BEGIN;


SELECT plan(2);

select tests.security_invoker_enabled_on_views('public');

-- drop all views in public schema as they do not work with tests.rls_enabled
DO
$$
DECLARE
  row record;
BEGIN

  FOR row IN SELECT viewname FROM pg_views AS t WHERE t.schemaname = 'public'
  LOOP
      EXECUTE format('DROP VIEW IF EXISTS public.%I CASCADE;', row.viewname);
  END LOOP;

END;
$$;
-- Verify RLS is enabled on all tables in the public schema
select tests.rls_enabled('public');

SELECT * FROM finish();
ROLLBACK;
