import { useQuery } from "@tanstack/react-query";
import { GameId } from "../type-aliases";
import { useSupabase } from "../providers/supabase";

export const useGameBoard = (gameId: GameId) => {
	const supabase = useSupabase();
	return useQuery({
		queryKey: ["game", gameId, "board"],
		queryFn: async () => {
			const response = await supabase
				.from("game_fields")
				.select("*")
				.eq("game_id", gameId);
			if (response.error) {
				throw new Error(response.error.message);
			}

			return response.data;
		},
	});
};
