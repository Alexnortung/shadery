-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.lobby_player_join(the_lobby_id uuid)
 RETURNS bigint
 LANGUAGE plpgsql
AS $function$
declare
    player lobby_players%rowtype;
    lobby lobbies%rowtype;
    next_player_number int;
begin
    -- Get the lobby
    select l.* into lobby
    from lobbies l
    where l.id = the_lobby_id;

    if not found then
        raise exception 'Lobby not found';
    end if;

    -- Check if the lobby is active
    if lobby.ended_at is not null then
        raise exception 'Lobby has ended';
    end if;

    -- Get the next player number
    select coalesce(max(lp.player_number) + 1, 0) into next_player_number
    from lobby_players lp
    where lp.lobby_id = the_lobby_id;

    -- Create the player
    insert into lobby_players (lobby_id, player_number)
    values (the_lobby_id, next_player_number)
    returning * into player;

    return player.id;
end;
$function$
;

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.user_create_lobby()
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
    new_lobby_id lobbies.id%type;
    new_player_id lobby_players.id%type;
begin
    -- Creates a new lobby
    -- Makes the user join the lobby

    insert into lobbies default values returning id into new_lobby_id;

    select user_join_lobby(new_lobby_id) into new_player_id;

    return new_lobby_id;
end;
$function$
;

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
    insert into auth_lobby (auth.uid, player_id)
    values (auth.uid(), lobby_player_id)
    returning player_id into lobby_player_id;

    return lobby_player_id;
end;
$function$
;

-- AUTHZ_UPDATE: Adding a permissive policy could allow unauthorized access to data.
CREATE POLICY "Allow users to see their lobby links" ON "public"."auth_lobby"
	AS PERMISSIVE
	FOR SELECT
	TO PUBLIC
	USING ((auth_uid = auth.uid()));

-- AUTHZ_UPDATE: Removing a permissive policy could cause queries to fail if not correctly configured.
DROP POLICY "Allow users to create lobbies" ON "public"."lobbies";

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For drops, this means you need to ensure that all functions this function depends on are dropped after this statement.
DROP FUNCTION "public"."lobby_player_join"(the_lobby_id bigint);

