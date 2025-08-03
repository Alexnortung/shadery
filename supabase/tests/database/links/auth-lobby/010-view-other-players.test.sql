BEGIN;
SELECT plan(2);

select tests.create_supabase_user('user1@test.example.com');
select tests.create_supabase_user('user2@test.example.com');

select tests.authenticate_as('user1@test.example.com');
select * from user_create_lobby() \gset lobby_

select tests.authenticate_as('user2@test.example.com');
select user_join_lobby(quote_literal(:'lobby_id'));

select isnt_empty(
    'select id from lobbies where id = ' || quote_literal(:'lobby_id'),
    'User 2 can see the lobby they joined'
);

select isnt_empty(
    'select * from auth_lobby where auth_uid = ' || quote_literal(tests.get_supabase_uid('user2@test.example.com')),
    'User 2 can see user 1 from auth_lobby'
)

SELECT * FROM finish();
ROLLBACK;
