-- AUTHZ_UPDATE: Adding a permissive policy could allow unauthorized access to data.
CREATE POLICY "Allow players to see other players in games they are part of" ON "public"."game_players"
	AS PERMISSIVE
	FOR SELECT
	TO PUBLIC
	USING ((game_id IN ( SELECT auth_game_get_user_games.id
   FROM auth_game_get_user_games() auth_game_get_user_games(id, size_x, size_y, current_player_number, ended_at, created_at))));

