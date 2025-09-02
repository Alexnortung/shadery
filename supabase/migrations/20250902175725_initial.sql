-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.game_generate_board(the_game_id bigint, size_x integer, size_y integer, num_field_values integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
    -- Insert new fields with random values
    insert into game_fields (game_id, x, y, field_value)
    select 
        the_game_id,
        x,
        y,
        floor(random() * num_field_values)::int as field_value
    from generate_series(0, size_x - 1) as x,
         generate_series(0, size_y - 1) as y;
end;
$function$
;

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.lobby_game_create_players(the_lobby_id uuid)
 RETURNS SETOF bigint
 LANGUAGE plpgsql
AS $function$
begin
    return query
    insert into game_players (game_id, player_number)
    select lg.game_id, p.player_number
    from lobby_players p
    inner join lobby_game lg on p.lobby_id = lg.lobby_id
    where p.lobby_id = the_lobby_id
    returning p.id;
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
    the_game_players game_players.id%type;
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
    insert into game_players (game_id, player_number)
    select the_game_id, p.player_number
    from lobby_players p
    where lobby_id = the_lobby_id
    returning id into the_game_players;

    -- link auth users to the game players
    insert into auth_game (player_id, auth_uid)
    select gp.id as game_player_id,
           lp.auth_uid as user_auth_uid
    from lobby_players lp
    inner join lobby_game lg on lp.lobby_id = lg.lobby_id
    inner join game_players gp on lg.game_id = gp.game_id
    where lp.lobby_id = the_lobby_id
    and lp.player_number = gp.player_number

    returning gp.id;
end;
$function$
;

ALTER TABLE "public"."games" ALTER COLUMN "current_player_number" SET DEFAULT 0;

ALTER TABLE "public"."lobby_game" ADD COLUMN "created_at" timestamp with time zone NOT NULL DEFAULT now();

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For drops, this means you need to ensure that all functions this function depends on are dropped after this statement.
DROP FUNCTION "public"."generate_board"(the_game_id bigint, size_x integer, size_y integer, num_field_values integer);

