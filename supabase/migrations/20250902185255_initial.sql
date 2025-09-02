-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.game_generate_player_position_by_number_simple(the_game_id bigint, the_player_number integer)
 RETURNS TABLE(position_x integer, position_y integer)
 LANGUAGE plpgsql
AS $function$
declare
    game_size_x games.size_x%type;
    game_size_y games.size_y%type;
    -- total_players int;
begin
    select g.size_x, g.size_y into game_size_x, game_size_y
    from games g
    where g.id = the_game_id;

    -- select count(*) into total_players
    -- from game_players p
    -- where p.game_id = the_game_id;
    if game_size_x is null or game_size_y is null then
        raise exception 'Game with id % does not exist', the_game_id;
    end if;
    if the_player_number < 0 then
        raise exception 'Player number % is invalid', the_player_number;
    end if;

    -- Simple logic: place players in corners
    -- if the_player_number = 0 then
    --     position_x := 0;
    --     position_y := 0;
    -- elsif the_player_number = 1 then
    --     position_x := game_size_x - 1;
    --     position_y := game_size_y - 1;
    -- elsif the_player_number = 2 then
    --     position_x := 0;
    --     position_y := game_size_y - 1;
    -- elsif the_player_number = 3 then
    --     position_x := game_size_x - 1;
    --     position_y := 0;
    -- else
    --     -- For additional players, place them in a spiral or grid pattern
    --     position_x := (the_player_number * 2) % game_size_x;
    --     position_y := (the_player_number * 3) % game_size_y;
    -- end if;

    return query
    select 
        case when the_player_number = 0 then 0
             when the_player_number = 1 then game_size_x - 1
             when the_player_number = 2 then 0
             when the_player_number = 3 then game_size_x - 1
             else (the_player_number * 2) % game_size_x
        end as position_x,
        case when the_player_number = 0 then 0
             when the_player_number = 1 then game_size_y - 1
             when the_player_number = 2 then game_size_y - 1
             when the_player_number = 3 then 0
             else (the_player_number * 3) % game_size_y
        end as position_y;
end;
$function$
;

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.user_lobby_start_game(the_lobby_id uuid)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
    the_game_id games.id%type;
    -- the_game_players game_players.id%type;
begin
    -- create game
    insert into games (size_x, size_y)
    values (10, 10)  -- Example size, adjust as needed
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

