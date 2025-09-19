begin;

select plan(1);

select tests.create_supabase_user('user1@test.example.com');
select tests.create_supabase_user('user2@test.example.com');

select tests.authenticate_as('user1@test.example.com');

select user_create_lobby();
select * from lobbies order by created_at desc limit 1 \gset lobby_
;

select tests.authenticate_as('user2@test.example.com');

select user_join_lobby(:'lobby_id');

select tests.authenticate_as('user1@test.example.com');

-- start the game
select user_lobby_start_game(:'lobby_id');

-- check that the lobby is ended
select isnt_empty(
    'select id from lobbies where id = ' || quote_literal(:'lobby_id') || ' and ended_at is not null',
    'Lobby is ended after starting the game'
);

select * from finish();
rollback;
