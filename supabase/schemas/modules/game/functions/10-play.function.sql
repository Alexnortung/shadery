create or replace function game_set_next_player(
    the_game_id games.id%type,
    player_number game_players.player_number%type
)
returns void
language plpgsql
as $$
declare
    next_player_number game_players.player_number%type;
begin
    -- get the next player
    select p.player_number into next_player_number
    from game_players p
    where p.game_id = the_game_id
    and p.player_number > game_set_next_player.player_number
    order by p.player_number asc
    limit 1;

    if next_player_number is null then
        -- get the first player instead
        select p.player_number into next_player_number
        from game_players p
        where p.game_id = the_game_id
        order by p.player_number asc
        limit 1;
    end if;

    -- update the current player number in the game table
    update games g
    set current_player_number = next_player_number
    where g.id = the_game_id;
end;
$$;

-- create or replace function game_get_scores(
--     the_game_id games.id%type
-- )
-- returns table(
--     player_id game_players.id%type,
--     player_number game_players.player_number%type,
--     score bigint
-- )
-- language plpgsql
-- as $$
-- begin
--     return query
--     select p.id, p.player_number, count(*) as score
--     from game_players p
--     left join game_fields f on f.field_value = p.initial_field_value
--     where p.game_id = the_game_id
--     group by p.id, p.player_number
--     order by score desc, p.player_number desc;
-- end;
-- $$;

create or replace function game_find_winner(
    the_game_id games.id%type
)
returns game_players.id%type
language plpgsql
as $$
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
$$;

create or replace function game_play_logic(
    the_game_id bigint,
    player_number int,
    value int
)
returns void
language plpgsql
as $$
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
$$;
