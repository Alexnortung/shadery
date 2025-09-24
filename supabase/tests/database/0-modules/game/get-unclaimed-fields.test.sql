begin;
select plan(2);

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
    'select game_id, field_value, x, y from game_get_unclaimed_fields(' || quote_literal(:game_id) || ')',
    'select ' || quote_literal(:game_id) || '::bigint as game_id, 2 as field_value, 1 as x, 0 as y',
    'get_unclaimed_fields should return the unclaimed fields'
);

insert into game_fields (game_id, x, y, field_value) values
    (:game_id, 0, 1, 0)
;

select results_eq(
    'select game_id, field_value, x, y from game_get_unclaimed_fields(' || quote_literal(:game_id) || ')',
    'select ' || quote_literal(:game_id) || '::bigint as game_id, 2 as field_value, 1 as x, 0 as y',
    'get_unclaimed_fields should return the unclaimed fields'
);

select * from finish();
rollback;
