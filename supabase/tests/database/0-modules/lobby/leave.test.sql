begin;
select plan(3);

insert into lobbies (created_at) values (now()) returning id \gset lobby_
;

insert into lobby_players (lobby_id, player_number) values (:'lobby_id', 0) returning id \gset player1_
;

insert into lobby_players (lobby_id, player_number) values (:'lobby_id', 1) returning id \gset player2_
;

select lives_ok(
    'select lobby_player_leave(' || quote_literal(:'lobby_id') || ', ' || quote_literal(:'player1_id') || '::bigint)',
    'Player 1 should be able to leave the lobby'
);

select lives_ok(
    'update lobbies set ended_at = now() where id = ' || quote_literal(:'lobby_id'),
    'Lobby should be ended manually'
);

select throws_ok(
    'select lobby_player_leave(' || quote_literal(:'lobby_id') || ', ' || quote_literal(:'player2_id') || '::bigint)',
    'Lobby has ended',
    'Player 2 should not be able to leave the ended lobby'
);

select * from finish();
rollback;
