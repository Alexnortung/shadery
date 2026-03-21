create table game_next_lobby (
    game_id bigint
        references games(id) on delete cascade
        not null
        unique,
    lobby_id uuid
        references lobbies(id) on delete cascade
        not null,
    created_at timestamp with time zone default now() not null
);
alter table "game_next_lobby" enable row level security;
