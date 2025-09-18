import { useQuery, useQueryClient } from "@tanstack/react-query";
import { LobbyId } from "../type-aliases";
import { createClient } from "@/utils/supabase/client";
import { useEffect } from "react";

export const useLobbyPlayers = ({
	lobbyId,
}: {
	lobbyId: LobbyId;
}) => {
	const queryClient = useQueryClient();
	useEffect(() => {
		const supabase = createClient();
		const channel = supabase
			.channel("table:lobby_players:lobbyId=eq.${lobbyId}")
			.on(
				"postgres_changes",
				{
					event: "*",
					schema: "public",
					table: "lobby_players",
					filter: `lobby_id=eq.${lobbyId}`,
				},
				(payload) => {
					// Invalidate and refetch
					queryClient.invalidateQueries({
						queryKey: ["lobby", lobbyId, "players"],
					});
				},
			)
			.subscribe();

		return () => {
			supabase.removeChannel(channel);
		};
	}, [lobbyId, queryClient]);

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
