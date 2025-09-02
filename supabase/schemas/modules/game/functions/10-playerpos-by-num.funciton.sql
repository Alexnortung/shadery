create or replace function game_generate_player_position_by_number_simple(
    the_game_id games.id%type,
    the_player_number game_players.player_number%type
)
returns table(position_x int, position_y int)
language plpgsql
as $$
declare
    game_size_x games.size_x%type;
    game_size_y games.size_y%type;
    -- total_players int;
begin
    select g.size_x, g.size_y into game_size_x, game_size_y
    from games g
    where g.id = the_game_id;

    -- select count(*) into total_players
    -- from game_players p
    -- where p.game_id = the_game_id;
    if game_size_x is null or game_size_y is null then
        raise exception 'Game with id % does not exist', the_game_id;
    end if;
    if the_player_number < 0 then
        raise exception 'Player number % is invalid', the_player_number;
    end if;

    -- Simple logic: place players in corners
    -- if the_player_number = 0 then
    --     position_x := 0;
    --     position_y := 0;
    -- elsif the_player_number = 1 then
    --     position_x := game_size_x - 1;
    --     position_y := game_size_y - 1;
    -- elsif the_player_number = 2 then
    --     position_x := 0;
    --     position_y := game_size_y - 1;
    -- elsif the_player_number = 3 then
    --     position_x := game_size_x - 1;
    --     position_y := 0;
    -- else
    --     -- For additional players, place them in a spiral or grid pattern
    --     position_x := (the_player_number * 2) % game_size_x;
    --     position_y := (the_player_number * 3) % game_size_y;
    -- end if;

    return query
    select 
        case when the_player_number = 0 then 0
             when the_player_number = 1 then game_size_x - 1
             when the_player_number = 2 then 0
             when the_player_number = 3 then game_size_x - 1
             else (the_player_number * 2) % game_size_x
        end as position_x,
        case when the_player_number = 0 then 0
             when the_player_number = 1 then game_size_y - 1
             when the_player_number = 2 then game_size_y - 1
             when the_player_number = 3 then 0
             else (the_player_number * 3) % game_size_y
        end as position_y;
end;
$$;
