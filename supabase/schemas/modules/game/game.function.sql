
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

create or replace function game_get_players_current_fields_ids(
    player_id bigint
)
returns setof bigint
language plpgsql
as $$
declare
    initial_pos_x int;
    initial_pos_y int;
begin
    -- return query
    -- select f.id
    -- from game_fields f
    select p.position_x into initial_pos_x,
        p.position_y into initial_pos_y
    from game_players p
    where p.player_id = player_id;

    with recursive
        fields as (
            select f.* from game_fields f
            where f.x = initial_pos_x
            and f.y = initial_pos_y
            union
            select f.* from game_fields f
            where f.value = fields.value
            and (
                (f.x = fields.x + 1 and f.y = fields.y)
                or (f.x = fields.x - 1 and f.y = fields.y)
                or (f.x = fields.x and f.y = fields.y + 1)
                or (f.x = fields.x and f.y = fields.y - 1)
            )
        )
    )
    select f.id as field_id
    from fields f
end;
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
