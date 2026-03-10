-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.user_lobby_start_game(the_lobby_id uuid)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
    the_game_id games.id%type;
    the_starting_player_number game_players.player_number%type;
    -- the_game_players game_players.id%type;
begin
    select coalesce(min(player_number), 0) into the_starting_player_number
    from lobby_players
    where lobby_id = the_lobby_id;

    -- create game
    insert into games (size_x, size_y, current_player_number)
    values (10, 10, the_starting_player_number)  -- Example size, adjust as needed
    returning id into the_game_id;

    -- create lobby game link
    insert into lobby_game (lobby_id, game_id)
    values (the_lobby_id, the_game_id);

    -- create board for game
    perform game_generate_board(the_game_id, 10, 10, 6);

    -- create a game player for each lobby player
    insert into game_players (game_id, player_number, position_x, position_y)
    select the_game_id, p.player_number, pos.position_x, pos.position_y
        -- game_generate_player_position_by_number_simple(the_game_id, p.player_number).*
    from
        lobby_players p,
        LATERAL game_generate_player_position_by_number_simple(the_game_id, p.player_number) pos
    where p.lobby_id = the_lobby_id
    -- returning id into the_game_players;
    ;

    -- link auth users to the game players
    insert into auth_game (player_id, auth_uid)
    select gp.id as game_player_id,
           al.auth_uid as user_auth_uid
    from lobby_players lp
    inner join auth_lobby al on lp.id = al.player_id
    inner join lobby_game lg on lp.lobby_id = lg.lobby_id
    inner join game_players gp on lg.game_id = gp.game_id
    where lp.lobby_id = the_lobby_id
    and lp.player_number = gp.player_number;

    return the_game_id;
end;
$function$
;

