-- A function which gets the fields in a game for each players position
create function game_get_players_initial_fields(
    the_game_id games.id%type
)
returns setof game_fields
language plpgsql
as $$
begin
    return query
    select f.*
    from game_fields f
    inner join game_players p on p.game_id = f.game_id
    where f.game_id = the_game_id
    and f.x = p.position_x
    and f.y = p.position_y
    ;
end;
$$;
