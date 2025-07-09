alter policy "Allow users to see players in their lobbies"
  on "lobby_players"
  using (
    lobby_players.lobby_id in (
        select current_p.lobby_id
        from auth_lobby al
        inner join lobby_players current_p
            on al.player_id = current_p.id
        where al.auth_uid = auth.uid()
    )
  );
