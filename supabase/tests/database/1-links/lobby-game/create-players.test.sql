begin;
select plan(1);

-- pass
select ok(true);

-- Setup lobby with two players
-- create a game

-- create function _test_create_lobby_and_players()
-- returns void as $$
-- declare
--     the_lobby_id lobbies.id%type;
--     the_lobby_player_ids int[];
--     the_game_id games.id%type;
-- begin
--     insert into lobbies (created_at)
--     values (now())
--     returning id into the_lobby_id;
--
--     insert into lobby_players (lobby_id, player_number, created_at)
--     values (the_lobby_id, 1, now()),
--            (the_lobby_id, 2, now())
--     returning id into the_lobby_player_ids;
--
--     insert into games (created_at)
--     values (now())
--     returning id into the_game_id;
--
--     insert into lobby_game (lobby_id, game_id)
--     values (the_lobby_id, the_game_id);
--
--     select lives_ok(
--         'SELECT lobby_game_create_players(' || quote_literal(the_lobby_id) || ')'
--     );
--
--     -- make sure two players were created
--     select results_eq(
--         'SELECT '
--     );
-- end;
-- $$ language plpgsql;
--
-- select _test_create_lobby_and_players();

select * from finish();
rollback;
