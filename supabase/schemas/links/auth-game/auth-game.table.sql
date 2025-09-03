create table auth_game (
    auth_uid uuid not null,
    -- a player id can only be used once in this table
    player_id bigint
        references game_players(id) on delete cascade
        not null
        unique
);
alter table "auth_game" enable row level security;
alter table auth_game
    add constraint auth_game_pkey primary key (auth_uid, player_id);
