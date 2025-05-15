INSERT INTO games (
    id,
    size_x,
    size_y,
    current_player_number
) VALUES ( 1, 20, 20, 0 );

INSERT INTO game_players (
    id,
    game_id,
    player_number,
    position_x,
    position_y
) VALUES ( 1, 1, 0, 0, 0 );

INSERT INTO game_fields (
    game_id,
    x,
    y,
    field_value
) VALUES
    ( 1, 0, 0, 1 ),
    ( 1, 0, 1, 1 ),
    ( 1, 0, 2, 1 ),
    ( 1, 0, 3, 0 ),
    ( 1, 0, 4, 0 ),
    ( 1, 0, 5, 0 ),
    ( 1, 0, 6, 0 ),
    ( 1, 0, 7, 0 ),
    ( 1, 0, 8, 0 ),
    ( 1, 0, 9, 0 ),

    ( 1, 1, 0, 1 ),
    ( 1, 1, 1, 1 ),
    ( 1, 1, 2, 1 ),
    ( 1, 1, 3, 0 ),
    ( 1, 1, 4, 0 ),
    ( 1, 1, 5, 0 ),
    ( 1, 1, 6, 0 ),
    ( 1, 1, 7, 0 ),
    ( 1, 1, 8, 0 ),
    ( 1, 1, 9, 0 );
