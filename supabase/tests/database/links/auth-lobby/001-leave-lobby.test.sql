BEGIN;

-- start_ignore
\set test_uuid 'ed8f6c70-04b7-4d3c-9393-8b6c6909e5ae'
-- end_ignore

-- Start declaring the number of test cases
SELECT plan(2);

select tests.create_supabase_user('user1@test.example.com');

insert into lobbies (id)
values (:'test_uuid');

insert into lobby_players (lobby_id, player_number)
values (:'test_uuid', 1)
RETURNING id \gset player_

insert into auth_lobby (auth_uid, player_id)
values (tests.get_supabase_uid('user1@test.example.com'), :'player_id');

-- Test: User can leave a lobby
select tests.authenticate_as('user1@test.example.com');

-- select results_eq(
--     'SELECT id FROM lobbies WHERE id = ' || quote_literal(:'test_uuid'),
--     ARRAY[:'test_uuid'::uuid],
--     'User should be able to see the lobby they are in'
-- );

select isnt_empty(
    'select * from auth_lobby where auth_uid = auth.uid()',
    'User should be able to see the lobby they are in'
);

select user_leave_lobby(:'test_uuid');

select is_empty(
    'SELECT * FROM auth_lobby WHERE auth_uid = auth.uid()',
    'User should not be able to see the lobby after leaving'
);

-- select is_empty(
--     'SELECT id FROM lobbies WHERE id = ' || quote_literal(:'test_uuid'),
--     'User should not be able to list the lobby after leaving'
-- );

SELECT * FROM finish();
ROLLBACK;
