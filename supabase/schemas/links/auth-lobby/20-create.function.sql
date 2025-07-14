create or replace function user_create_lobby()
returns lobbies.id%type
language plpgsql
security definer
as $$
declare
    new_lobby_id lobbies.id%type;
    new_player_id lobby_players.id%type;
begin
    -- Creates a new lobby
    -- Makes the user join the lobby

    insert into lobbies default values returning id into new_lobby_id;

    select user_join_lobby(new_lobby_id) into new_player_id;

    return new_lobby_id;
end;
$$;
