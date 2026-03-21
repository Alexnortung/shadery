BEGIN;
SELECT plan(4);

select tests.create_supabase_user('user1@test.example.com');
select tests.create_supabase_user('user2@test.example.com');

-- given an ended game. The first user to call user_game_join_next_lobby should create a new lobby and join it. The second user should join the same lobby, when they call user_game_join_next_lobby.

select tests.__create_game_with_players(12345678, ARRAY[
    tests.get_supabase_uid('user1@test.example.com'),
    tests.get_supabase_uid('user2@test.example.com')
]);
update games set ended_at = now() where id = 12345678;

select tests.authenticate_as('user1@test.example.com');

select lives_ok(
    'select user_game_join_next_lobby(12345678)',
    'user1 should create and join a new lobby for the ended game'
);

select tests.authenticate_as_service_role();

-- create a temporary table to store the lobby id, so we can verify that the second user joins the same lobby.
CREATE TEMP TABLE temp_lobby_id AS
SELECT * FROM get_user_lobby_ids_by_user(tests.get_supabase_uid('user1@test.example.com')) AS t(lobby_id);

-- expect that there is exactly one lobby id in the temp table
select results_eq(
    'select count(*) from temp_lobby_id',
    $$values (1::bigint)$$,
    'The user should have joined exactly one lobby'
);

select tests.authenticate_as('user2@test.example.com');

select lives_ok(
    'select user_game_join_next_lobby(12345678)',
    'user2 should be able to call user_game_join_next_lobby and join the same lobby as user1 for the ended game'
);

select tests.authenticate_as_service_role();

select results_eq(
    'select lobby_id from temp_lobby_id',
    'select lobby_id from get_user_lobby_ids_by_user(' || quote_literal(tests.get_supabase_uid('user2@test.example.com')) || ') as t(lobby_id)',
    'The second user should have joined the same lobby as the first user'
);

SELECT * FROM finish();
ROLLBACK;
