create or replace function user_lobby_start_game(
    the_lobby_id lobbies.id%type
)
returns games.id%type
language plpgsql
security definer
as $$
declare
  game_id games.id%type;
begin
    
end;
$$;
