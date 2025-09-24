begin;
select plan(5);

insert into games (size_x, size_y) values (3, 1) returning id \gset game_
;

insert into game_fields (game_id, x, y, field_value) values
    (:game_id, 0, 0, 0),
    (:game_id, 1, 0, 2),
    (:game_id, 2, 0, 1)
;

insert into game_players (game_id, player_number, position_x, position_y) values
    (:game_id, 0, 0, 0) returning id \gset player1_
;

insert into game_players (game_id, player_number, position_x, position_y) values
    (:game_id, 1, 2, 0) returning id \gset player2_
;

select results_eq(
    'select game_find_winner(' || quote_literal(:'game_id') || ')',
    'select null::bigint',
    'find_winner should return null when no player has the majority of the fields'
);

select lives_ok(
    'select game_play_logic(' || quote_literal(:'game_id') || ', 0, 2)',
    'player 1 plays at value 2 and should win after that'
);

select results_eq(
    'select game_find_winner(' || quote_literal(:'game_id') || ')',
    'select ' || quote_literal(:'player1_id') || '::bigint',
    'find_winner should return player 1 which now has more than 50% of the fields'
);

select tests.freeze_time(now());

select results_eq(
    'select ended_at from games where id = ' || quote_literal(:'game_id'),
    'select now()',
    'game should be ended after a player has won'
);

select tests.unfreeze_time();

select throws_ok(
    'select game_play_logic(' || quote_literal(:'game_id') || ', 1, 1)',
    'Game has already ended',
    'playing on an ended game should throw an error'
);

select * from finish();
rollback;
