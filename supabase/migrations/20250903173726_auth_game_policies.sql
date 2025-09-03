-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.auth_game_get_user_games()
 RETURNS SETOF games
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
    return query
    select g.*
    from auth_game ag
    inner join game_players gp
        on ag.player_id = gp.id
    inner join games g
        on gp.game_id = g.id
    where ag.auth_uid = auth.uid();
end;
$function$
;

-- AUTHZ_UPDATE: Adding a permissive policy could allow unauthorized access to data.
CREATE POLICY "Allow players to see fields in games they are part of" ON "public"."game_fields"
	AS PERMISSIVE
	FOR SELECT
	TO PUBLIC
	USING ((game_id IN ( SELECT auth_game_get_user_games.id
   FROM auth_game_get_user_games() auth_game_get_user_games(id, size_x, size_y, current_player_number, ended_at, created_at))));

-- AUTHZ_UPDATE: Adding a permissive policy could allow unauthorized access to data.
CREATE POLICY "Allow players to see games they are part of" ON "public"."games"
	AS PERMISSIVE
	FOR SELECT
	TO PUBLIC
	USING ((id IN ( SELECT auth_game_get_user_games.id
   FROM auth_game_get_user_games() auth_game_get_user_games(id, size_x, size_y, current_player_number, ended_at, created_at))));

