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

select results_eq(
    'select x, y, field_value from game_get_players_initial_fields(' || quote_literal(:'game_id') || '::bigint)',
    $$VALUES (0, 0, 0)$$,
    'Player 1 should have initial field at (0,0) with value 0'
);

insert into game_players (game_id, player_number, position_x, position_y) values (:'game_id', 1, 9, 9) returning id \gset player2_
;

select results_eq(
    'select x, y, field_value from game_get_players_initial_fields(' || quote_literal(:'game_id') || '::bigint)',
    $$VALUES (0, 0, 0), (9, 9, 1)$$,
    'game_get_players_initial_fields should return both players initial fields correctly'
);

select * from finish();
end;
