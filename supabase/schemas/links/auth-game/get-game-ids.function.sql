create function auth_game_get_user_games()
returns setof games
language plpgsql
security definer
as $$
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
$$;
