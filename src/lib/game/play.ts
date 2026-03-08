import { createClient } from "@/utils/supabase/client";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { GameId } from "../type-aliases";

export const usePlay = () => {
	const queryClient = useQueryClient();
	const supabase = createClient();
	return useMutation({
		mutationKey: ["game", "play"],
		mutationFn: async ({
			value,
			gameId,
		}: {
			value: number;
			gameId: GameId;
		}) => {
			const response = await supabase.rpc("user_game_player_play", {
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
