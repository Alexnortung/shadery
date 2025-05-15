create table "games" (
    "id" serial primary key,
    "size_x" int not null,
    "size_y" int not null,
    "current_player_number" int,
    "ended_at" timestamp with time zone,
    "created_at" timestamp with time zone default now()
);

create table "game_players" (
    "id" serial primary key,
    "game_id" bigint references games(id) on delete cascade,
    "position_x" int,
    "position_y" int,
    "player_number" int not null
);

create table "game_fields" (
    "id" serial primary key,
    "game_id" bigint references games(id) on delete cascade,
    "field_value" int,
    "x" int,
    "y" int,
    constraint "uq_field_position" unique ("game_id", "x", "y")
);
