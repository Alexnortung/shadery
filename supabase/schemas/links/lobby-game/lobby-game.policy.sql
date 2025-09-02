create policy "lobby_game: Allow users to view games that are part of lobbies"
    on "lobby_game"
    for select
    using (
        lobby_game.lobby_id IN (
            select get_user_lobby_ids()
        )
    );

-- create policy "lobby_game: Allow users to view lobbies that are part of their games"
--     on "lobby_game"
--     for select
--     using (
--         lobby_game.game_id IN (
--             select get_user_game_ids() -- Call the function here
--         )
--     );
