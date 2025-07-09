alter policy "Allow users to create lobbies"
    on "lobbies"
    to public, authenticated
    with check (true);
