create table auth_game (
    auth_uid uuid,
    player_id bigint references game_players(id) on delete cascade
);
