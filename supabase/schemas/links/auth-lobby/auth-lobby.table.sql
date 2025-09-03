create table auth_lobby (
    auth_uid uuid not null,
    player_id bigint
        references lobby_players(id) on delete cascade
        not null
        unique
);
alter table "auth_lobby" enable row level security;
alter table auth_lobby
    add constraint auth_lobby_pkey primary key (auth_uid, player_id);
