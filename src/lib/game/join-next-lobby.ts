import { useMutation, useQuery } from "@tanstack/react-query";
import { useSupabase } from "../providers/supabase";
import { GameId } from "../type-aliases";

export const useJoinNextLobby = (gameId: GameId) => {
	const supabase = useSupabase();
	return useMutation({
		mutationKey: ["join-next-lobby", gameId],
		mutationFn: async () => {
			const { data: nextLobbyId, error } = await supabase.rpc(
				"user_game_join_next_lobby",
				{
					the_game_id: gameId,
				},
			);

			if (error) {
				throw error;
			}

			return nextLobbyId;
		},
	});
};
