-- AUTHZ_UPDATE: Adding a permissive policy could allow unauthorized access to data.
CREATE POLICY "lobby_game: Allow users to view games that are part of lobbies" ON "public"."lobby_game"
	AS PERMISSIVE
	FOR SELECT
	TO PUBLIC
	USING ((lobby_id IN ( SELECT get_user_lobby_ids() AS get_user_lobby_ids)));

alter publication supabase_realtime
    add table lobby_game;
