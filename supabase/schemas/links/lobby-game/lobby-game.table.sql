create table lobby_game (
    lobby_id uuid
        references lobbies(id) on delete cascade
        not null
        unique,
    -- a player id can only be used once in this table
    game_id bigint
        references games(id) on delete cascade
        not null
        unique,
    created_at timestamp with time zone default now() not null
);
alter table "lobby_game" enable row level security;
