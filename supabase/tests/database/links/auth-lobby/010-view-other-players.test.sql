BEGIN;

SELECT plan(5);

select tests.create_supabase_user('user1@test.example.com');
select tests.create_supabase_user('user2@test.example.com');

select tests.authenticate_as('user1@test.example.com');

select is_empty(
    'select id from lobbies',
    'User 1 can not see any lobbies before creating one'
);

select user_create_lobby();
select * from lobbies order by created_at desc limit 1 \gset lobby_
;

select isnt_empty(
    'select id from lobbies where id = ' || quote_literal(:'lobby_id'),
    'User 1 can see the lobby they created'
);

select tests.authenticate_as('user2@test.example.com');

select is_empty(
    'select id from lobbies',
    'User 2 can not see the lobby when not joined'
);

select user_join_lobby(:'lobby_id');

select isnt_empty(
    'select id from lobbies',
    'User 2 can see the lobby they joined'
);

select isnt_empty(
    'select * from auth_lobby',
    'User 2 can see user 1 from auth_lobby'
);

SELECT * FROM finish();
ROLLBACK;
