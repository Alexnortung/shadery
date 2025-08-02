BEGIN;
SELECT plan(1);

-- Verify RLS is enabled on all tables in the public schema
select tests.rls_enabled('public');

SELECT * FROM finish();
ROLLBACK;
