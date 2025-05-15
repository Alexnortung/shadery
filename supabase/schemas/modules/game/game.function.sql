
-- A function which gets the game player based on the game id
create or replace function game_get_player(
    game_id bigint
)
returns game_players
language plpgsql
as $$
begin
    return (
        select *
        from game_players p
        inner join auth_game ag
            on p.player_id = ag.player_id
        where game_id = game_id
        and ag.auth_uid = auth.uid()
    );
end;
$$;

-- A security definer function which allows a user to make a play
create or replace function game_player_play(
    game_id bigint,
    value int
)
returns void
language plpgsql
security definer
as $$
declare
    player game_players%rowtype;
    game games%rowtype;
begin
    -- Get the game
    select g.* into game
    from games g
    where g.id = game_id;

    if not found then
        raise exception 'Game not found';
    end if;

    -- Get the player
    select * into player
    from game_get_player(game_id);
    
    if not found then
        raise exception 'Player not found';
    end if;

    -- check if the game is active
    if game.ended_at is not null then
        raise exception 'Game has ended';
    end if;

    -- check if it is currently the player's turn
    if game.current_player != player.player_number then
        raise exception 'It is not your turn';
    end if;

    -- TODO: check if the value is valid

    -- Run play logic
end;
$$;

create or replace function game_set_next_player(
    game_id bigint,
    player_number int
)
returns void
language plpgsql
as $$
declare
    next_player int;
begin
    -- get the next player
    select p.player_number into next_player
    from game_players p
    where p.game_id = game_id
    and p.player_number > player_number
    order by p.player_number asc
    limit 1;

    if next_player is null then
        -- get the first player instead
        select p.player_number into next_player
        from game_players p
        where p.game_id = game_id
        order by p.player_number asc
        limit 1;
    end if;

    -- update the current player number in the game table
    update game g
    set current_player = next_player
    where g.id = game_id;
end;
$$;

CREATE OR REPLACE FUNCTION game_get_players_current_fields_ids(
    player_id BIGINT
)
RETURNS SETOF BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    the_game_id BIGINT;
    initial_pos_x INT;
    initial_pos_y INT;
BEGIN
    -- Get initial player position
    SELECT p.game_id, p.position_x, p.position_y
    INTO the_game_id, initial_pos_x, initial_pos_y
    FROM game_players p
    WHERE p.id = player_id;

    -- Recursive search for connected fields with same value
    RETURN QUERY
    WITH RECURSIVE fields AS (
        SELECT f.id, f.x, f.y, f.field_value
        FROM game_fields f
        WHERE f.game_id = the_game_id AND f.x = initial_pos_x AND f.y = initial_pos_y

        UNION

        SELECT f2.id, f2.x, f2.y, f2.field_value
        FROM game_fields f2
        INNER JOIN fields f1 ON f2.game_id = the_game_id AND f2.field_value = f1.field_value AND (
            (f2.x = f1.x + 1 AND f2.y = f1.y) OR
            (f2.x = f1.x - 1 AND f2.y = f1.y) OR
            (f2.x = f1.x AND f2.y = f1.y + 1) OR
            (f2.x = f1.x AND f2.y = f1.y - 1)
        )
    )
    SELECT id FROM fields;
END;
$$;

create or replace function game_play_logic(
    game_id bigint,
    player_number int,
    value int
)
returns void
language plpgsql
as $$
declare
    next_player int;
begin
    -- TODO: implement play logic
    -- for now, just upate the current player turn
    perform set_next_player(game_id, player_number);
end;
$$;
