import { createClient } from "@/utils/supabase/client";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { GameId } from "../type-aliases";

export const usePlay = () => {
	const queryClient = useQueryClient();
	return useMutation({
		mutationKey: ["game", "play"],
		mutationFn: async ({
			value,
			gameId,
		}: { value: number; gameId: GameId }) => {
			const supbase = createClient();
			const response = await supbase.rpc("user_game_player_play", {
				value,
				the_game_id: gameId,
			});

			if (response.error) {
				throw response.error;
			}

			// return response.data;
		},
		onSettled: (data, error, variables) => {
			const { gameId } = variables;
			queryClient.invalidateQueries({ queryKey: ["game", gameId, "board"] });
		},
	});
};
