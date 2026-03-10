CREATE VIEW "public"."auth_joined_lobby" WITH (security_invoker=true) AS
 SELECT DISTINCT l.id AS lobby_id,
    al.auth_uid
   FROM lobbies l
     JOIN lobby_players lp ON l.id = lp.lobby_id
     JOIN auth_lobby al ON lp.id = al.player_id;;

