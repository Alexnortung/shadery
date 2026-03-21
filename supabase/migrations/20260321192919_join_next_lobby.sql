-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.game_get_player_by_game_id(the_game_id bigint, the_auth_uid uuid)
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
        and ag.auth_uid = the_auth_uid
    );
end;
$function$
;

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.get_user_lobby_ids()
 RETURNS SETOF uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  RETURN QUERY
  SELECT get_user_lobby_ids_by_user(auth.uid());
END;
$function$
;

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.get_user_lobby_ids_by_user(the_auth_uid uuid)
 RETURNS SETOF uuid
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT lp.lobby_id
  FROM lobby_players lp
    JOIN auth_lobby al ON al.player_id = lp.id
    WHERE al.auth_uid = the_auth_uid;
END;
$function$
;

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.user_game_join_next_lobby(the_game_id bigint)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
    the_lobby_id lobbies.id%type;
begin
    -- Check that the user is part of the game by using user_get_game_player
    if not exists (
        select 1 from user_get_game_player(the_game_id)
    ) then
        raise exception 'User is not part of the game';
    end if;

    -- Check if the game already has a next lobby
    -- Then check if the lobby was started.
    -- - If not started, join the lobby and return the lobby id.
    -- - If started raise an exception that the lobby is already started.

    select lobby_id into the_lobby_id
    from game_next_lobby
    where game_id = the_game_id;

    if the_lobby_id is not null then
        if (select ended_at from lobbies where id = the_lobby_id) is null then
            -- Lobby not started, join the lobby
            perform user_join_lobby(the_lobby_id);
            return the_lobby_id;
        else
            -- Lobby already started
            raise exception 'Lobby already started';
        end if;
    end if;

    -- Creates a new lobby
    select user_create_lobby() into the_lobby_id;

    -- Update the game with the next lobby id
    insert into game_next_lobby (game_id, lobby_id)
    values (the_game_id, the_lobby_id);

    return the_lobby_id;
end;
$function$
;

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.user_get_game_player(the_game_id bigint)
 RETURNS SETOF game_players
 LANGUAGE plpgsql
AS $function$
begin
    return query select game_get_player_by_game_id(
        the_game_id,
        auth.uid()
    );
end;
$function$
;

CREATE TABLE "public"."game_next_lobby" (
	"game_id" bigint NOT NULL,
	"lobby_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE "public"."game_next_lobby" ENABLE ROW LEVEL SECURITY;

GRANT DELETE ON "public"."game_next_lobby" TO "anon";

GRANT INSERT ON "public"."game_next_lobby" TO "anon";

GRANT MAINTAIN ON "public"."game_next_lobby" TO "anon";

GRANT REFERENCES ON "public"."game_next_lobby" TO "anon";

GRANT SELECT ON "public"."game_next_lobby" TO "anon";

GRANT TRIGGER ON "public"."game_next_lobby" TO "anon";

GRANT TRUNCATE ON "public"."game_next_lobby" TO "anon";

GRANT UPDATE ON "public"."game_next_lobby" TO "anon";

GRANT DELETE ON "public"."game_next_lobby" TO "authenticated";

GRANT INSERT ON "public"."game_next_lobby" TO "authenticated";

GRANT MAINTAIN ON "public"."game_next_lobby" TO "authenticated";

GRANT REFERENCES ON "public"."game_next_lobby" TO "authenticated";

GRANT SELECT ON "public"."game_next_lobby" TO "authenticated";

GRANT TRIGGER ON "public"."game_next_lobby" TO "authenticated";

GRANT TRUNCATE ON "public"."game_next_lobby" TO "authenticated";

GRANT UPDATE ON "public"."game_next_lobby" TO "authenticated";

GRANT DELETE ON "public"."game_next_lobby" TO "service_role";

GRANT INSERT ON "public"."game_next_lobby" TO "service_role";

GRANT MAINTAIN ON "public"."game_next_lobby" TO "service_role";

GRANT REFERENCES ON "public"."game_next_lobby" TO "service_role";

GRANT SELECT ON "public"."game_next_lobby" TO "service_role";

GRANT TRIGGER ON "public"."game_next_lobby" TO "service_role";

GRANT TRUNCATE ON "public"."game_next_lobby" TO "service_role";

GRANT UPDATE ON "public"."game_next_lobby" TO "service_role";

CREATE UNIQUE INDEX game_next_lobby_game_id_key ON public.game_next_lobby USING btree (game_id);

ALTER TABLE "public"."game_next_lobby" ADD CONSTRAINT "game_next_lobby_game_id_key" UNIQUE USING INDEX "game_next_lobby_game_id_key";

ALTER TABLE "public"."game_next_lobby" ADD CONSTRAINT "game_next_lobby_game_id_fkey" FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE NOT VALID;

ALTER TABLE "public"."game_next_lobby" VALIDATE CONSTRAINT "game_next_lobby_game_id_fkey";

ALTER TABLE "public"."game_next_lobby" ADD CONSTRAINT "game_next_lobby_lobby_id_fkey" FOREIGN KEY (lobby_id) REFERENCES lobbies(id) ON DELETE CASCADE NOT VALID;

ALTER TABLE "public"."game_next_lobby" VALIDATE CONSTRAINT "game_next_lobby_lobby_id_fkey";

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.user_game_join_next_lobby(the_game_id bigint)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    the_lobby_id lobbies.id%type;
BEGIN
    -- Check that the user is part of the game by using user_get_game_player
    IF NOT EXISTS (
        SELECT 1 FROM user_get_game_player(the_game_id)
    ) THEN
        RAISE EXCEPTION 'User is not part of the game';
    END IF;

    -- Check if the game already has a next lobby
    select lobby_id into the_lobby_id
    from game_next_lobby
    where game_id = the_game_id;

    if the_lobby_id is not null then
        if (select ended_at from lobbies where id = the_lobby_id) is null then
            -- Lobby not started, join the lobby
            perform user_join_lobby(the_lobby_id);
            return the_lobby_id;
        else
            -- Lobby already started
            raise exception 'Lobby already started';
        end if;
    end if;

    -- Creates a new lobby
    the_lobby_id := user_create_lobby();

    -- Update the game with the next lobby id
    INSERT INTO game_next_lobby (game_id, lobby_id)
    VALUES (the_game_id, the_lobby_id);

    RETURN the_lobby_id;
END;
$function$
;

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.user_get_game_player(the_game_id bigint)
 RETURNS SETOF game_players
 LANGUAGE plpgsql
AS $function$
begin
    return query select * from game_get_player_by_game_id(
        the_game_id,
        auth.uid()
    );
end;
$function$
;

