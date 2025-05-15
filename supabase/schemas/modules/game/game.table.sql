create table "games" (
    "id" bigserial primary key,
    "size_x" int not null,
    "size_y" int not null,
    "current_player_number" int not null,
    "ended_at" timestamp with time zone,
    "created_at" timestamp with time zone not null default now()
);

create table "game_players" (
    "id" bigserial primary key,
    "game_id" bigint references games(id) on delete cascade,
    "position_x" int not null,
    "position_y" int not null,
    "player_number" int not null
);

create table "game_fields" (
    "id" bigserial primary key,
    "game_id" bigint references games(id) on delete cascade,
    "field_value" int,
    "x" int not null,
    "y" int not null,
    constraint "uq_field_position" unique ("game_id", "x", "y")
);
