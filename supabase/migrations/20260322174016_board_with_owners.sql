CREATE OR REPLACE VIEW "public"."game_fields_with_owners" WITH (security_invoker=true) AS
 SELECT gf.id,
    gf.game_id,
    gf.field_value,
    gf.x,
    gf.y,
    owner_data.player_id AS owner_player_id,
    owner_data.player_number AS owner_player_number
   FROM game_fields gf
     LEFT JOIN ( SELECT gp.game_id,
            gp.id AS player_id,
            gp.player_number,
            owned_field_id.owned_field_id
           FROM game_players gp
             CROSS JOIN LATERAL game_get_players_current_fields_ids(gp.id) owned_field_id(owned_field_id)) owner_data ON gf.id = owner_data.owned_field_id AND gf.game_id = owner_data.game_id;;

