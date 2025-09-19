begin;
select plan(9);

insert into games (size_x, size_y) values (10, 10) returning id \gset game_
;

insert into game_players (game_id, player_number, position_x, position_y) values (:'game_id', 0, 0, 0) returning id \gset player1_
;

insert into game_players (game_id, player_number, position_x, position_y) values (:'game_id', 1, 9, 9) returning id \gset player2_
;

select lives_ok(
    'SELECT game_generate_board(' || quote_literal(:'game_id') || '::bigint, 10, 10, 4)',
    'Game board should be generated successfully'
);

-- Ensure player 1 has value 0
select results_eq(
    'SELECT field_value FROM game_fields WHERE game_id = ' || quote_literal(:'game_id') || '::bigint AND x = 0 AND y = 0',
    $$VALUES (0)$$,
    'Player 1 should have player_number 0'
);

-- Ensure player 2 has value 1
select results_eq(
    'SELECT field_value FROM game_fields WHERE game_id = ' || quote_literal(:'game_id') || '::bigint AND x = 9 AND y = 9',
    $$VALUES (1)$$,
    'Player 2 should have player_number 1'
);

-- Player 1 cannot play 0 or 1 because player 1 should have value 0 and player 2 should have value 1
select throws_ok('select game_play_logic(' || quote_literal(:'game_id') || '::bigint, 0, 0)');
select throws_ok('select game_play_logic(' || quote_literal(:'game_id') || '::bigint, 0, 1)');

-- Player 1 can play 2
select lives_ok('select game_play_logic(' || quote_literal(:'game_id') || '::bigint, 0, 2)', 'Player 1 should be able to play 2');

-- Player 2 should not be able to play 1 or 2
select throws_ok('select game_play_logic(' || quote_literal(:'game_id') || '::bigint, 1, 1)');
select throws_ok('select game_play_logic(' || quote_literal(:'game_id') || '::bigint, 1, 2)');

-- Player 2 should be able to play 0
select lives_ok('select game_play_logic(' || quote_literal(:'game_id') || '::bigint, 1, 0)', 'Player 2 should be able to play 0');

select * from finish();
rollback;
