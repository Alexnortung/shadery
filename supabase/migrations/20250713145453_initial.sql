-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.user_join_lobby(the_lobby_id uuid)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

