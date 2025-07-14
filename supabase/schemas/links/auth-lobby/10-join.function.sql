create or replace function user_join_lobby(
    the_lobby_id lobbies.id%type
)
returns lobby_players.id%type
-- returns void
language plpgsql
security definer
as $$
declare
    lobby_player_id lobby_players.id%type;
begin
    select lobby_player_join(the_lobby_id) into lobby_player_id;

    -- If the player is already in the lobby, raise an exception
    if lobby_player_id is null then
        raise exception 'You are already in this lobby';
    end if;
    
    -- Insert the auth_lobby link
    insert into auth_lobby (auth_uid, player_id)
    values (auth.uid(), lobby_player_id)
    returning player_id into lobby_player_id;

    return lobby_player_id;
end;
$$;
