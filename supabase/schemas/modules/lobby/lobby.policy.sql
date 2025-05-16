alter table "lobbies" enable row level security;
alter table "lobby_players" enable row level security;

-- Allow a user to create a lobby
create policy "Allow users to create lobbies"
    on "lobbies"
    for insert
    using (true);

-- Joining a lobby is done by using the join_lobby function

-- Allow a user to see lobbies that they are a part of
create policy "Allow users to see their lobbies"
    on "lobbies" l
    for select
    using (
        exists (
            select 1
            from auth_lobby al
            inner join lobby_players p
                on al.player_id = p.id
            where al.auth_uid = auth.uid()
            and p.lobby_id = l.id
        )
    );

-- Allow a user to see the players in a lobby
create policy "Allow users to see players in their lobbies"
    on "lobby_players" lp
    for select
    using (
        exists (
            select 1
            from auth_lobby al
            inner join lobby_players p
                on al.player_id = p.id
            where al.auth_uid = auth.uid()
            and p.lobby_id = lp.lobby_id
        )
    );
