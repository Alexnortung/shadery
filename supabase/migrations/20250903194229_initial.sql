alter publication supabase_realtime
    add table games;

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.user_game_player_play(the_game_id bigint, value integer)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
    player game_players%rowtype;
    game games%rowtype;
begin
    -- Get the game
    select g.* into game
    from games g
    where g.id = the_game_id;

    if not found then
        raise exception 'Game not found';
    end if;

    -- Get the player
    select * into player
    from user_get_game_player(the_game_id);
    
    if not found then
        raise exception 'Player not found';
    end if;

    -- check if the game is active
    if game.ended_at is not null then
        raise exception 'Game has ended';
    end if;

    -- check if it is currently the player's turn
    if game.current_player_number != player.player_number then
        raise exception 'It is not your turn';
    end if;

    -- TODO: check if the value is valid

    -- Run play logic
    perform game_play_logic(the_game_id, player.player_number, value);
end;
$function$
;

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
DROP FUNCTION IF EXISTS public.user_get_game_player(bigint);
CREATE OR REPLACE FUNCTION public.user_get_game_player(the_game_id bigint)
 RETURNS SETOF game_players
 LANGUAGE plpgsql
AS $function$
begin
    return query (
        select p.*
        from game_players p
        inner join auth_game ag
            on p.id = ag.player_id
        where p.game_id = the_game_id
        and ag.auth_uid = auth.uid()
    );
end;
$function$
;

