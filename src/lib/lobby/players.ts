import { useQuery, useQueryClient } from "@tanstack/react-query";
import { LobbyId } from "../type-aliases";
import { createClient } from "@/utils/supabase/client";
import { useEffect } from "react";
import { atom } from "jotai";
import { useConnectionSubscription } from "../socket-manager/new/hooks";

// export const useRealtimePlayers = ({ lobbyId }: { lobbyId: LobbyId}) => {
// 	const q = useQuery({
// 		queryKey: ["realtime", "lobby", lobbyId, "players"],
// 		behavior
// 	})
// };

export const useLobbyPlayers = ({
	lobbyId,
}: {
	lobbyId: LobbyId;
}) => {
	const queryClient = useQueryClient();

	useConnectionSubscription(
		{
			key: `table:lobby_players:lobbyId=eq.${lobbyId}`,
			connectFn: ({ onMessage }) => {
				const supabase = createClient();
				const channel = supabase
					.channel(`table:lobby_players:lobbyId=eq.${lobbyId}`)
					.on(
						"postgres_changes",
						{
							event: "*",
							schema: "public",
							table: "lobby_players",
							filter: `lobby_id=eq.${lobbyId}`,
						},
						(payload) => {
							onMessage(payload);
						},
					)
					.subscribe();

				return {
					disconnectFn: () => {
						supabase.removeChannel(channel);
					},
				};
			},
		},
		{
			key: `lobby-players-updated`,
			listener: () => {
				// Invalidate and refetch
				queryClient.invalidateQueries({
					queryKey: ["lobby", lobbyId, "players"],
				});
			},
		},
	);

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

export const useHasJoinedLobby = () => {};
