create or replace view game_fields_with_owners with (security_invoker = true) as
select 
    gf.id,
    gf.game_id,
    gf.field_value,
    gf.x,
    gf.y,
    owner_data.player_id as owner_player_id,
    owner_data.player_number as owner_player_number
from game_fields gf
left join (
    -- 1. Get every player (including game_id to optimize the join)
    -- 2. LATERAL runs the function for each player's ID 
    -- 3. This creates a virtual table mapping player_id to field_id
    select 
        gp.game_id,
        gp.id as player_id,
        gp.player_number,
        owned_field_id
    from game_players gp
    cross join lateral game_get_players_current_fields_ids(gp.id) as owned_field_id
) owner_data on gf.id = owner_data.owned_field_id and gf.game_id = owner_data.game_id;
