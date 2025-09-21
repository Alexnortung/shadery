CREATE OR REPLACE FUNCTION game_get_players_current_fields_ids(
    player_id game_players.id%type
)
RETURNS SETOF game_fields.id%type
LANGUAGE plpgsql
AS $$
DECLARE
    the_game_id games.id%type;
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

create or replace function game_get_unclaimed_fields(
    the_game_id games.id%type
)
returns setof game_fields
language plpgsql
as $$
begin
    return query
    select f.*
    from game_fields f
    where f.game_id = the_game_id
    and f.id not in (
        select unnest(game_get_players_current_fields_ids(p.id))
        from game_players p
        where p.game_id = the_game_id
    )
    ;
end;
$$;
