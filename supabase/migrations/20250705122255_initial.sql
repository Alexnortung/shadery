drop policy "Allow users to see players in their lobbies" on "public"."lobby_players";

create policy "Allow users to see players in their lobbies"
on "public"."lobby_players"
as permissive
for select
to public
using ((EXISTS ( SELECT 1
   FROM (auth_lobby al
     JOIN lobby_players current_player ON ((al.player_id = current_player.id)))
  WHERE ((al.auth_uid = auth.uid()) AND (current_player.id = al.player_id) AND (lobby_players.lobby_id = current_player.lobby_id)))));



