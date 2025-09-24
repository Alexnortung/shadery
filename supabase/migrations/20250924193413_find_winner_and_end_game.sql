create or replace view game_player_with_score with (security_invoker = true) as
select
    p.id,
    p.game_id,
    p.player_number,
    (select count(*) from game_get_players_current_fields_ids(p.id)) as score
from game_players p
;

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.game_find_winner(the_game_id bigint)
 RETURNS bigint
 LANGUAGE plpgsql
AS $function$
declare
    total_fields bigint;
    winner_id game_players.id%type;
begin
    select count(*) into total_fields
    from game_fields f
    where f.game_id = the_game_id;

    -- If a player has more than 50% of the fields, they win
    select p.id into winner_id
    from game_player_with_score p
    where p.game_id = the_game_id
    and p.score > total_fields / 2
    order by p.score desc, p.player_number desc
    limit 1;

    if winner_id is not null then
        return winner_id;
    end if;

    -- TODO: If a player has more fields than all other players owned fields + reachable fields, the player wins.

    -- If all fields are taken, the player with the most fields wins
    -- If it is a tie, the player who started last wins (the player with the highest player number)
    if (select count(*) from game_get_unclaimed_fields(the_game_id)) <= 0 then
        select p.id into winner_id
        from game_player_with_score p
        where p.game_id = the_game_id
        order by p.score desc, p.player_number desc
        limit 1;
    end if;

    return winner_id;
end;
$function$
;

-- HAS_UNTRACKABLE_DEPENDENCIES: Dependencies, i.e. other functions used in the function body, of non-sql functions cannot be tracked. As a result, we cannot guarantee that function dependencies are ordered properly relative to this statement. For adds, this means you need to ensure that all functions this function depends on are created/altered before this statement.
CREATE OR REPLACE FUNCTION public.game_get_unclaimed_fields(the_game_id bigint)
 RETURNS SETOF game_fields
 LANGUAGE plpgsql
AS $function$
begin
    return query
    select f.*
    from game_fields f
    where f.game_id = the_game_id
    and f.id not in (
        select game_get_players_current_fields_ids(p.id)
        from game_players p
        where p.game_id = the_game_id
    )
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
    player_id game_players.id%type;
    winner_id game_players.id%type;
begin
    if (select g.ended_at is not null from games g where g.id = the_game_id) then
        raise exception 'Game has already ended';
    end if;

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

    select game_find_winner(the_game_id) into winner_id;
    if winner_id is not null then
        update games g
        set 
            -- winner_id = winner_id,
            ended_at = now()
        where g.id = the_game_id;
    end if;
end;
$function$
;

