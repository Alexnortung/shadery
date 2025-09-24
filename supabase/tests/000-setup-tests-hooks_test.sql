-- install tests utilities
-- install pgtap extension for testing
create extension if not exists pgtap with schema extensions;
/*
---------------------
---- install dbdev ----
----------------------
Requires:
  - pg_tle: https://github.com/aws/pg_tle
  - pgsql-http: https://github.com/pramsey/pgsql-http
*/
create extension if not exists http with schema extensions;
create extension if not exists pg_tle;
drop extension if exists "supabase-dbdev";
select pgtle.uninstall_extension_if_exists('supabase-dbdev');
select
    pgtle.install_extension(
        'supabase-dbdev',
        resp.contents ->> 'version',
        'PostgreSQL package manager',
        resp.contents ->> 'sql'
    )
from http(
    (
        'GET',
        'https://api.database.dev/rest/v1/'
        || 'package_versions?select=sql,version'
        || '&package_name=eq.supabase-dbdev'
        || '&order=version.desc'
        || '&limit=1',
        array[
            ('apiKey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhtdXB0cHBsZnZpaWZyYndtbXR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODAxMDczNzIsImV4cCI6MTk5NTY4MzM3Mn0.z2CN0mvO2No8wSi46Gw59DFGCTJrzM0AQKsu_5k134s')::http_header
        ],
        null,
        null
    )
) x,
lateral (
    select
        ((row_to_json(x) -> 'content') #>> '{}')::json -> 0
) resp(contents);
create extension "supabase-dbdev";
select dbdev.install('supabase-dbdev');
drop extension if exists "supabase-dbdev";
create extension "supabase-dbdev";
-- Install test helpers
select dbdev.install('basejump-supabase_test_helpers');
create extension if not exists "basejump-supabase_test_helpers" version '0.0.6';

-- test that security_invoker has been enabled for all views in the given schema
create or replace function tests.security_invoker_enabled_on_views(p_schema text)
returns text
language sql
as $_func_$
  select is_empty(
    format($$
      select
          relname
        from pg_class
        join pg_catalog.pg_namespace n on n.oid = pg_class.relnamespace
        where n.nspname = %L -- filter on the schema
          and relkind='v' -- only select views
          and (
            -- if reloptions is null then the array check does
            -- not work as you might expect :s (I think it might resolve
            -- to null and then not null becomes false or something)
            reloptions is null or
            not (
              -- lower case the options text and extract array, then check if any
              -- elements match elements in our array of possibilities for the
              -- security_invoker option being enabled
              lower(reloptions::text)::text[] &&
              array['security_invoker=1','security_invoker=true','security_invoker=on']
            )
          )
    $$, p_schema),
    format('The security_invoker option should be enabled for all views in the %L schema', p_schema)
  );
$_func_$;

-- Verify setup with a no-op test
begin;
select plan(1);
select ok(true, 'Pre-test hook completed successfully');
select * from finish();
rollback;
