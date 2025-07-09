-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.get_user_lobby_ids()
 RETURNS SETOF uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  RETURN QUERY
  SELECT lp.lobby_id
  FROM lobby_players lp
    JOIN auth_lobby al ON al.player_id = lp.id
    WHERE al.auth_uid = auth.uid();
END;
$function$
;

-- AUTHZ_UPDATE: Altering a policy could cause queries to fail if not correctly configured or allow unauthorized access to data.
ALTER POLICY "Allow users to see players in their lobbies" ON "public"."lobby_players"
	USING ((lobby_id IN ( SELECT get_user_lobby_ids() AS get_user_lobby_ids)));

