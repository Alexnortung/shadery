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
