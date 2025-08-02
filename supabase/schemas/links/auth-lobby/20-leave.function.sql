create or replace function user_leave_lobby(
    the_lobby_id lobbies.id%type
)
returns void
language plpgsql
security definer
as $$
declare
  lobby_player_id lobby_players.id%type;
begin
  select lp.id into lobby_player_id
  from lobby_players lp
  inner join auth_lobby al
    on lp.id = al.player_id
  where al.auth_uid = auth.uid()
  and lp.lobby_id = the_lobby_id
  limit 1;

  perform lobby_player_leave(the_lobby_id, lobby_player_id);

  delete from auth_lobby
  where auth_uid = auth.uid()
  and player_id = lobby_player_id;
end;
$$;
