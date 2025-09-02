begin;
select plan(2);

insert into games (size_x, size_y) values (10, 10) returning id \gset game_
;

select results_eq(
    'select * from game_generate_player_position_by_number_simple(' || quote_literal(:'game_id') || ', 0)',
    -- array[[0,0]],
    $$values (0, 0)$$,
    'Player 0 should be at (0,0)'
);

select results_eq(
    'select * from game_generate_player_position_by_number_simple(' || quote_literal(:'game_id') || ', 1)',
    -- array[[9,9]],
    $$values (9, 9)$$,
    'Player 1 should be at (9,9)'
);

select * from finish();
rollback;
