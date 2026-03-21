create or replace function tests.__create_game_with_players (
    the_game_id games.id%type,
    the_auth_uids uuid ARRAY
)
returns void
language plpgsql
security definer
as $$
begin
    insert into games (id, size_x, size_y) values (the_game_id, 10, 10);

    WITH limited_users AS (
        SELECT unnest(the_auth_uids) AS id
        LIMIT 2
    ),
    selected_users AS (
        -- 1. Generate an incrementing number (1 and 2) for our 2 users
        SELECT 
            id AS auth_uid, 
            ROW_NUMBER() OVER () AS player_num
        FROM limited_users
    ),
    inserted_players AS (
        -- 2. Insert into game_players using the incrementing number
        INSERT INTO game_players (game_id, position_x, position_y, player_number)
        SELECT 
            the_game_id,
            player_num,
            0,
            player_num
        FROM selected_users
        RETURNING id AS player_id, player_number
    )
    -- 3. Map the newly created player_id to the correct auth_uid
    INSERT INTO auth_game (auth_uid, player_id)
    SELECT 
        su.auth_uid, 
        ip.player_id
    FROM selected_users su
    JOIN inserted_players ip ON su.player_num = ip.player_number;
end;
$$;

begin;
select plan(1);
select ok(true, 'Pre-test lobby-game utils completed successfully');
select * from finish();
rollback;
