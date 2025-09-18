alter publication supabase_realtime
    add table lobby_players;

ALTER TABLE lobby_players REPLICA IDENTITY FULL;
