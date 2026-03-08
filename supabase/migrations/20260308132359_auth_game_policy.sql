-- AUTHZ_UPDATE: Adding a permissive policy could allow unauthorized access to data.
CREATE POLICY "Allow players to see all user ids of players in games they are " ON "public"."auth_game"
	AS PERMISSIVE
	FOR SELECT
	TO PUBLIC
	USING ((player_id IN ( SELECT game_players.id
   FROM game_players
  WHERE (game_players.game_id IN ( SELECT auth_game_get_user_games.id
           FROM auth_game_get_user_games() auth_game_get_user_games(id, size_x, size_y, current_player_number, ended_at, created_at))))));

