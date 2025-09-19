-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.lobby_player_leave(the_lobby_id uuid, the_player_id bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
    if lobby.ended_at is not null then
        raise exception 'Lobby has ended';
    end if;

    -- Currently we just delete the player entry. I am not sure if this needs to be different for auditing.
    delete from lobby_players
    where id = the_player_id
    and lobby_id = the_lobby_id;
end;
$function$
;

