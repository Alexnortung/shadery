-- -- Allow a user to create a lobby
-- create policy "Allow users to create lobbies"
--     on "lobbies"
--     for insert
--     to public, authenticated
--     with check (true);

-- Joining a lobby is done by using the join_lobby function

create policy "Allow users to see their lobby links"
    on "auth_lobby"
    for select
    using (
        auth_lobby.auth_uid = auth.uid()
    );

-- Allow a user to see lobbies that they are a part of
create policy "Allow users to see their lobbies"
    on "lobbies"
    for select
    using (
        exists (
            select 1
            from auth_lobby al
            inner join lobby_players p
                on al.player_id = p.id
            -- inner join lobbies l
            --     on p.lobby_id = l.id
            where al.auth_uid = auth.uid()
            and p.lobby_id = lobbies.id
        )
    );

-- Allow a user to see the players in a lobby
create policy "Allow users to see players in their lobbies"
  on "lobby_players"
  for select
  using (
    lobby_players.lobby_id IN (
      select get_user_lobby_ids() -- Call the function here
    )
  );

create policy "Allow users to see players auth links in their lobbies"
    on "auth_lobby"
    for select
    using (
        auth_lobby.player_id IN (
            select id
            from lobby_players
            where lobby_players.lobby_id IN (select get_user_lobby_ids())
        )
    )
