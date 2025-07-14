import { Database } from "@/supabase/types";

export type LobbyId = Database["public"]["Tables"]["lobbies"]["Row"]["id"];
