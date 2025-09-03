-- A function which gets the game player based on the game id
create or replace function user_get_game_player(
    the_game_id bigint
)
returns setof game_players
language plpgsql
as $$
begin
    return query (
        select p.*
        from game_players p
        inner join auth_game ag
            on p.id = ag.player_id
        where p.game_id = the_game_id
        and ag.auth_uid = auth.uid()
    );
end;
$$;
