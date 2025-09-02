begin;
select plan(4);

insert into games (size_x, size_y, current_player_number)
values (100, 100, 0)
returning id \gset game_
;

-- ensure that the fields have not been generated yet
select is_empty(
    'SELECT * FROM game_fields WHERE game_id = ' || quote_literal(:'game_id'),
    'Game fields should not be generated yet'
);

-- select game_generate_board(:'game_id', 10, 10, 10);
select lives_ok(
    'SELECT game_generate_board(' || quote_literal(:'game_id') || '::bigint, 100, 100, 4)',
    'Game board should be generated successfully'
);

-- ensure that the 100 fields for the game has been generated
select results_eq(
    'SELECT COUNT(*) FROM game_fields WHERE game_id = ' || quote_literal(:'game_id'),
    ARRAY[10000::bigint],
    'Game fields should be generated successfully'
);

-- ensure that the fields have been generated with random values
-- This test might fail if the random values are not diverse enough, but it is unlikely
select results_eq(
    'SELECT COUNT(DISTINCT field_value) FROM game_fields WHERE game_id = ' || quote_literal(:'game_id'),
    ARRAY[4::bigint],
    'Game fields should have 10 distinct values'
);

select * from finish();
rollback;
