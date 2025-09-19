-- Create a trigger that ends a lobby when a lobby_game record is inserted
create function end_lobby_after_game_connected()
returns trigger
language plpgsql
as $$
begin
    -- Update the lobby to set ended_at to now()
    update lobbies
    set ended_at = now()
    where id = new.lobby_id
    and ended_at is null;  -- Only end if not already ended

    return new;
end;
$$;

create trigger end_lobby_after_game_connected_trigger
after insert on lobby_game
for each row
execute function end_lobby_after_game_connected();
