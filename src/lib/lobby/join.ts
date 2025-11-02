import { useMutation, useQueryClient } from "@tanstack/react-query";
import { LobbyId } from "../type-aliases";
import { createClient } from "@/utils/supabase/client";

export const useJoinLobby = () => {
	const queryClient = useQueryClient();
	return useMutation({
		mutationKey: ["joinLobby"],
		mutationFn: async ({ lobbyId }: { lobbyId: LobbyId }) => {
			console.log("joining", lobbyId);
			const supabase = createClient();
			const lobbyPlayerIdResponse = await supabase.rpc("user_join_lobby", {
				the_lobby_id: lobbyId,
			});

			if (lobbyPlayerIdResponse.error) {
				throw lobbyPlayerIdResponse.error;
			}

			return lobbyPlayerIdResponse.data;
		},

		onSuccess: (lobbyPlayerId, { lobbyId }) => {
			console.log("Joined lobby", lobbyId, lobbyPlayerId);
			queryClient.invalidateQueries({
				queryKey: ["lobby", lobbyId],
			});
		},
	});
};
