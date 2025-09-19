begin;
select plan(3);


insert into games (size_x, size_y) values (10, 10) returning id \gset game_
;

select lives_ok(
    'SELECT game_generate_board(' || quote_literal(:'game_id') || '::bigint, 10, 10, 200)',
    'Game board should be generated successfully'
);

insert into game_players (game_id, player_number, position_x, position_y) values (:'game_id', 0, 0, 0) returning id \gset player1_
;

insert into game_players (game_id, player_number, position_x, position_y) values (:'game_id', 1, 9, 9) returning id \gset player2_
;

select results_eq(
    'SELECT field_value FROM game_fields WHERE game_id = ' || quote_literal(:'game_id') || '::bigint AND x = 0 AND y = 0',
    $$VALUES (0)$$,
    'Player 1 should have player_number 0'
);
select results_eq(
    'SELECT field_value FROM game_fields WHERE game_id = ' || quote_literal(:'game_id') || '::bigint AND x = 9 AND y = 9',
    $$VALUES (1)$$,
    'Player 2 should have player_number 1'
);

select * from finish();
rollback;
