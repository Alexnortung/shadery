import { useQuery } from "@tanstack/react-query";
import { LobbyId } from "../type-aliases";
import { createClient } from "@/utils/supabase/client";

export const useLobbyPlayers = ({
	lobbyId,
}: {
	lobbyId: LobbyId;
}) => {
	return useQuery({
		queryKey: ["lobby", lobbyId, "players"],
		queryFn: async () => {
			const supabase = createClient();
			const playerResponse = await supabase
				.from("lobby_players")
				.select(`
				id,
				auth_lobby (
					auth_uid
				)`)
				.eq("lobby_id", lobbyId);

			if (playerResponse.error) {
				throw new Error(playerResponse.error.message);
			}
			return playerResponse.data;
		},
	});
};
