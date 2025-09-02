-- This function generates a board with random fields where the fields' values are inclusively between 0 and the provided number of field values minus 1
create or replace function game_generate_board(
    the_game_id games.id%type,
    size_x INT,
    size_y INT,
    num_field_values game_fields.field_value%type
)
returns void
language plpgsql
as $$
begin
    -- Insert new fields with random values
    insert into game_fields (game_id, x, y, field_value)
    select 
        the_game_id,
        x,
        y,
        floor(random() * num_field_values)::int as field_value
    from generate_series(0, size_x - 1) as x,
         generate_series(0, size_y - 1) as y;
end;
$$;
