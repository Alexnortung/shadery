-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.game_ensure_player_value()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
    insert into game_fields (game_id, x, y, field_value)
    values (new.game_id, new.position_x, new.position_y, new.player_number)
    on conflict (game_id, x, y) do update
    set field_value = excluded.field_value
    ;

    return new;
end;
$function$
;

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.game_generate_board(the_game_id bigint, size_x integer, size_y integer, num_field_values integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
    -- Insert new fields with random values
    insert into game_fields (game_id, x, y, field_value)
    select 
        the_game_id,
        x,
        y,
        floor(random() * num_field_values)::int as field_value
    from generate_series(0, size_x - 1) as x,
         generate_series(0, size_y - 1) as y
    on conflict do nothing
    ;
end;
$function$
;

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.game_get_players_initial_fields(the_game_id bigint)
 RETURNS SETOF game_fields
 LANGUAGE plpgsql
AS $function$
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
$function$
;

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.game_play_logic(the_game_id bigint, player_number integer, value integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
    player_id bigint;
begin
    -- don't allow the player to play a value that is already held by another player
    if (select value in (select field_value from game_get_players_initial_fields(the_game_id))) then
        raise exception 'Value is already held by another player';
    end if;

    -- TODO: Only allow the player to play a value that is in the game

    -- update the game fields based on the player's fields
    select p.id into player_id
    from game_players p
    where p.game_id = the_game_id
    and p.player_number = game_play_logic.player_number;

    update game_fields f
    set field_value = value
    where f.id in (
        select * from game_get_players_current_fields_ids(player_id)
    );
    
    -- for now, just upate the current player turn
    perform game_set_next_player(the_game_id, player_number);

    -- TODO: check if a player has won
end;
$function$
;

CREATE TRIGGER game_ensure_player_value_trigger AFTER INSERT ON public.game_players FOR EACH ROW EXECUTE FUNCTION game_ensure_player_value();

