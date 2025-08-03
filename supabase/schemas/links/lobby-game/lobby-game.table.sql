create table lobby_game (
    lobby_id lobbies.id%type
        references lobbies(id) on delete cascade
        not null
        unique,
    -- a player id can only be used once in this table
    game_id games.id%type
        references games(id) on delete cascade
        not null
        unique,
);
alter table "lobby_game" enable row level security;
