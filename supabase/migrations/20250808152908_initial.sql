-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.game_get_players_current_fields_ids(player_id bigint)
 RETURNS SETOF bigint
 LANGUAGE plpgsql
AS $function$
DECLARE
    the_game_id games.id%type;
    initial_pos_x INT;
    initial_pos_y INT;
BEGIN
    -- Get initial player position
    SELECT p.game_id, p.position_x, p.position_y
    INTO the_game_id, initial_pos_x, initial_pos_y
    FROM game_players p
    WHERE p.id = player_id;

    -- Recursive search for connected fields with same value
    RETURN QUERY
    WITH RECURSIVE fields AS (
        SELECT f.id, f.x, f.y, f.field_value
        FROM game_fields f
        WHERE f.game_id = the_game_id AND f.x = initial_pos_x AND f.y = initial_pos_y

        UNION

        SELECT f2.id, f2.x, f2.y, f2.field_value
        FROM game_fields f2
        INNER JOIN fields f1 ON f2.game_id = the_game_id AND f2.field_value = f1.field_value AND (
            (f2.x = f1.x + 1 AND f2.y = f1.y) OR
            (f2.x = f1.x - 1 AND f2.y = f1.y) OR
            (f2.x = f1.x AND f2.y = f1.y + 1) OR
            (f2.x = f1.x AND f2.y = f1.y - 1)
        )
    )
    SELECT id FROM fields;
END;
$function$
;

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.game_set_next_player(the_game_id bigint, player_number integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
    next_player_number game_players.player_number%type;
begin
    -- get the next player
    select p.player_number into next_player_number
    from game_players p
    where p.game_id = the_game_id
    and p.player_number > game_set_next_player.player_number
    order by p.player_number asc
    limit 1;

    if next_player_number is null then
        -- get the first player instead
        select p.player_number into next_player_number
        from game_players p
        where p.game_id = the_game_id
        order by p.player_number asc
        limit 1;
    end if;

    -- update the current player number in the game table
    update games g
    set current_player_number = next_player_number
    where g.id = the_game_id;
end;
$function$
;

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.generate_board(the_game_id bigint, size_x integer, size_y integer, num_field_values integer)
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
    if game.current_player != player.player_number then
        raise exception 'It is not your turn';
    end if;

    -- TODO: check if the value is valid

    -- Run play logic
end;
$function$
;

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.user_get_game_player(the_game_id bigint)
 RETURNS game_players
 LANGUAGE plpgsql
AS $function$
begin
    return (
        select *
        from game_players p
        inner join auth_game ag
            on p.player_id = ag.player_id
        where p.game_id = the_game_id
        and ag.auth_uid = auth.uid()
    );
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
  game_id games.id%type;
begin
    
end;
$function$
;

CREATE TABLE "public"."lobby_game" (
	"lobby_id" uuid NOT NULL,
	"game_id" bigint NOT NULL
);

ALTER TABLE "public"."lobby_game" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."lobby_game" ADD CONSTRAINT "lobby_game_game_id_fkey" FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE NOT VALID;

ALTER TABLE "public"."lobby_game" VALIDATE CONSTRAINT "lobby_game_game_id_fkey";

ALTER TABLE "public"."lobby_game" ADD CONSTRAINT "lobby_game_lobby_id_fkey" FOREIGN KEY (lobby_id) REFERENCES lobbies(id) ON DELETE CASCADE NOT VALID;

ALTER TABLE "public"."lobby_game" VALIDATE CONSTRAINT "lobby_game_lobby_id_fkey";

CREATE UNIQUE INDEX lobby_game_game_id_key ON public.lobby_game USING btree (game_id);

ALTER TABLE "public"."lobby_game" ADD CONSTRAINT "lobby_game_game_id_key" UNIQUE USING INDEX "lobby_game_game_id_key";

CREATE UNIQUE INDEX lobby_game_lobby_id_key ON public.lobby_game USING btree (lobby_id);

ALTER TABLE "public"."lobby_game" ADD CONSTRAINT "lobby_game_lobby_id_key" UNIQUE USING INDEX "lobby_game_lobby_id_key";

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For drops, this means you need to ensure that all functions this function depends on are dropped after this statement.
DROP FUNCTION "public"."game_get_player"(the_game_id bigint);

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For drops, this means you need to ensure that all functions this function depends on are dropped after this statement.
DROP FUNCTION "public"."game_player_play"(the_game_id bigint, value integer);

