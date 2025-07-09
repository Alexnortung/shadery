-- AUTHZ_UPDATE: Altering a policy could cause queries to fail if not correctly configured or allow unauthorized access to data.
ALTER POLICY "Allow users to see players in their lobbies" ON "public"."lobby_players"
	USING ((EXISTS ( SELECT 1
   FROM (auth_lobby al
     JOIN lobby_players p ON ((al.player_id = p.id)))
  WHERE ((al.auth_uid = auth.uid()) AND (p.lobby_id = lobby_players.lobby_id)))));

