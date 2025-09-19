-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.end_lobby_after_game_connected()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
    -- Update the lobby to set ended_at to now()
    update lobbies
    set ended_at = now()
    where id = new.lobby_id
    and ended_at is null;  -- Only end if not already ended

    return new;
end;
$function$
;

CREATE TRIGGER end_lobby_after_game_connected_trigger AFTER INSERT ON public.lobby_game FOR EACH ROW EXECUTE FUNCTION end_lobby_after_game_connected();

