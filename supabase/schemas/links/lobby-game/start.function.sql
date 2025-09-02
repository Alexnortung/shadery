create or replace function user_lobby_start_game(
    the_lobby_id lobbies.id%type
)
returns games.id%type
language plpgsql
security definer
as $$
declare
    the_game_id games.id%type;
    -- the_game_players game_players.id%type;
begin
    -- create game
    insert into games (size_x, size_y)
    values (10, 10)  -- Example size, adjust as needed
    returning id into the_game_id;

    -- create lobby game link
    insert into lobby_game (lobby_id, game_id)
    values (the_lobby_id, the_game_id);

    -- create board for game
    perform game_generate_board(the_game_id, 10, 10, 6);

    -- create a game player for each lobby player
    insert into game_players (game_id, player_number, position_x, position_y)
    select the_game_id, p.player_number, pos.position_x, pos.position_y
        -- game_generate_player_position_by_number_simple(the_game_id, p.player_number).*
    from
        lobby_players p,
        LATERAL game_generate_player_position_by_number_simple(the_game_id, p.player_number) pos
    where p.lobby_id = the_lobby_id
    -- returning id into the_game_players;
    ;

    -- link auth users to the game players
    insert into auth_game (player_id, auth_uid)
    select gp.id as game_player_id,
           al.auth_uid as user_auth_uid
    from lobby_players lp
    inner join auth_lobby al on lp.id = al.player_id
    inner join lobby_game lg on lp.lobby_id = lg.lobby_id
    inner join game_players gp on lg.game_id = gp.game_id
    where lp.lobby_id = the_lobby_id
    and lp.player_number = gp.player_number;

    return the_game_id;
end;
$$;
