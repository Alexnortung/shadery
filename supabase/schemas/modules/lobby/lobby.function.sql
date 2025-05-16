create or replace function lobby_player_join(
    the_lobby_id bigint
)
-- returns the new player id
returns bigint
language plpgsql
as $$
declare
    player lobby_players%rowtype;
    lobby lobbies%rowtype;
    next_player_number int;
begin
    -- Get the lobby
    select l.* into lobby
    from lobbies l
    where l.id = the_lobby_id;

    if not found then
        raise exception 'Lobby not found';
    end if;

    -- Check if the lobby is active
    if lobby.ended_at is not null then
        raise exception 'Lobby has ended';
    end if;

    -- Get the next player number
    select coalesce(max(lp.player_number) + 1, 0) into next_player_number
    from lobby_players lp
    where lp.lobby_id = the_lobby_id;

    -- Create the player
    insert into lobby_players (lobby_id, player_number)
    values (the_lobby_id, next_player_number)
    returning * into player;

    return player.id;
end;
$$;
