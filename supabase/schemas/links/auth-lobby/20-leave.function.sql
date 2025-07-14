create or replace function user_leave_lobby(
    the_lobby_id lobbies.id%type
)
returns void
language plpgsql
security definer
as $$
declare
  lobby_player_id lobby_players
begin
  
end;
$$;
