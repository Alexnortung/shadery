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
