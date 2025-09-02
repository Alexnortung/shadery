begin;
select plan(3);

-- create two users
-- make the users join a lobby
-- start a game from the lobby
-- ensure that the game has been created with a board and two players

select tests.create_supabase_user('user1@test.example.com');
select tests.create_supabase_user('user2@test.example.com');

select tests.authenticate_as('user1@test.example.com');
select user_create_lobby() as id \gset lobby_
;

select tests.authenticate_as('user2@test.example.com');
select user_join_lobby(:'lobby_id');

select tests.authenticate_as('user1@test.example.com');

select tests.authenticate_as_service_role();

select user_lobby_start_game(:'lobby_id') as id \gset game_
;

-- make sure a game was created
select isnt_empty(
    'select * from games where id = ' || quote_literal(:'game_id'),
    'Game should have been created'
);

-- make sure a board was created
-- select isnt_empty(
--     'select count(*) from game_fields where game_id = ' || quote_literal(:'game_id'),
--     'Game board should have been created'
-- );
select isnt_empty(
    'select * from game_fields where game_id = ' || quote_literal(:'game_id') || ' and field_value is not null',
    'Game board should have been created with non-null values'
);

-- make sure two players were created
select results_eq(
    'select count(*) from game_players where game_id = ' || quote_literal(:'game_id'),
    $$values (2::bigint)$$,
    'Game should have two players'
);

-- make sure the players are linked to the auth users
-- select results_eq(
--     'select count(*) from auth_game' || quote_literal(:'game_id'),
--     array[2],
--     'Game players should be linked to the users'
-- );

select * from finish();
rollback;
