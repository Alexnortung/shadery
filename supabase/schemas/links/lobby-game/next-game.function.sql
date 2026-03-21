CREATE OR REPLACE FUNCTION user_game_join_next_lobby(
    the_game_id games.id%type
)
RETURNS lobbies.id%type
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    the_lobby_id lobbies.id%type;
BEGIN
    -- Check that the user is part of the game by using user_get_game_player
    IF NOT EXISTS (
        SELECT 1 FROM user_get_game_player(the_game_id)
    ) THEN
        RAISE EXCEPTION 'User is not part of the game';
    END IF;

    -- Check if the game already has a next lobby
    select lobby_id into the_lobby_id
    from game_next_lobby
    where game_id = the_game_id;

    if the_lobby_id is not null then
        if (select ended_at from lobbies where id = the_lobby_id) is null then
            -- Lobby not started, join the lobby
            perform user_join_lobby(the_lobby_id);
            return the_lobby_id;
        else
            -- Lobby already started
            raise exception 'Lobby already started';
        end if;
    end if;

    -- Creates a new lobby
    the_lobby_id := user_create_lobby();

    -- Update the game with the next lobby id
    INSERT INTO game_next_lobby (game_id, lobby_id)
    VALUES (the_game_id, the_lobby_id);

    RETURN the_lobby_id;
END;
$$;
