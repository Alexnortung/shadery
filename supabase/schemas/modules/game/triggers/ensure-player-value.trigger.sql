-- create a trigger to ensure that a player has it's initial value the same as it's player number
create function game_ensure_player_value()
returns trigger
language plpgsql
as $$
begin
    insert into game_fields (game_id, x, y, field_value)
    values (new.game_id, new.position_x, new.position_y, new.player_number)
    on conflict (game_id, x, y) do update
    set field_value = excluded.field_value
    ;

    return new;
end;
$$;

create trigger game_ensure_player_value_trigger
after insert on game_players
for each row
execute function game_ensure_player_value();
