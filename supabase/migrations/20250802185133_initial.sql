-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.lobby_player_leave(the_lobby_id uuid, the_player_id bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
    -- Currently we just delete the player entry. I am not sure if this needs to be different for auditing.
    delete from lobby_players
    where id = the_player_id
    and lobby_id = the_lobby_id;
end;
$function$
;

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.user_leave_lobby(the_lobby_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  lobby_player_id lobby_players.id%type;
begin
  select lp.id into lobby_player_id
  from lobby_players lp
  inner join auth_lobby al
    on lp.id = al.player_id
  where al.auth_uid = auth.uid()
  and lp.lobby_id = the_lobby_id
  limit 1;

  perform lobby_player_leave(the_lobby_id, lobby_player_id);

  delete from auth_lobby
  where auth_uid = auth.uid()
  and player_id = lobby_player_id;
end;
$function$
;

-- AUTHZ_UPDATE: Adding a permissive policy could allow unauthorized access to data.
CREATE POLICY "Allow users to see players auth links in their lobbies" ON "public"."auth_lobby"
	AS PERMISSIVE
	FOR SELECT
	TO PUBLIC
	USING ((player_id IN ( SELECT lobby_players.id
   FROM lobby_players
  WHERE (lobby_players.lobby_id IN ( SELECT get_user_lobby_ids() AS get_user_lobby_ids)))));

