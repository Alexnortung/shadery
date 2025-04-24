create table "game" (
    "id" serial primary key,
    "size_x" int not null,
    "size_y" int not null
);

create table "game_player" (
    "id" serial primary key,
    "game_id" bigint references "game" on delete cascade,
    "player_index" int not null,
);

create table "game_fields" (
    "id" serial primary key,
    "game_id" bigint references "game" on delete cascade,
    "field_value" int,
    "x" int,
    "y" int,
    unique key "uq_field_position" ("game_id", "x", "y")
);

-- Create a trigger that generates fields for the game
create or replace function generate_game_fields()
returns trigger as $$
declare
    x int;
    y int;
begin
    for x in 0..new.size_x - 1 loop
        for y in 0..new.size_y - 1 loop
            insert into game_fields (game_id, field_value, x, y)
            values (new.id, null, x, y);
        end loop;
    end loop;

    return new;
end;
$$ language plpgsql;
create trigger generate_game_fields_trigger
after insert on game
for each row
execute procedure generate_game_fields();
