-- creates game players for a lobby which has already been linked to a game
create or replace function lobby_game_create_players(
    the_lobby_id lobbies.id%type
)
returns setof game_players.id%type
language plpgsql
as $$
begin
    return query
    insert into game_players (game_id, player_number)
    select lg.game_id, p.player_number
    from lobby_players p
    inner join lobby_game lg on p.lobby_id = lg.lobby_id
    where p.lobby_id = the_lobby_id
    returning p.id;
end;
$$;
