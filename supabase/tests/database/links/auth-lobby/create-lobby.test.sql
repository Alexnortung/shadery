BEGIN;

-- Start declaring the number of test cases
SELECT plan(2);

select tests.create_supabase_user('user1@test.example.com');
select tests.create_supabase_user('user2@test.example.com');

-- Test: User can create a lobby
select tests.authenticate_as('user1@test.example.com');

select user_create_lobby();

select isnt_empty(
    'SELECT id FROM lobbies',
    'User should be able to create a lobby'
);

select isnt_empty(
    'SELECT * FROM auth_lobby',
    'User should be able to create an auth lobby'
);




SELECT * FROM finish();
ROLLBACK;
