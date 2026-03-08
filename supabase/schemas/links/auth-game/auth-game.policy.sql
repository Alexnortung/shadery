create policy "Allow players to see games they are part of"
    on games
    for select
    using (
        games.id IN (
            select id from auth_game_get_user_games()
        )
    );

create policy "Allow players to see fields in games they are part of"
    on game_fields
    for select
    using (
        game_fields.game_id IN (
            select id from auth_game_get_user_games()
        )
    );

create policy "Allow players to see other players in games they are part of"
    on game_players
    for select
    using (
        game_players.game_id IN (
            select id from auth_game_get_user_games()
        )
    );

create policy "Allow players to see all user ids of players in games they are part of"
    on auth_game
    for select
    using (
        auth_game.player_id IN (
            select id from game_players
            where game_id IN (
                select id from auth_game_get_user_games()
            )
        )
    );
