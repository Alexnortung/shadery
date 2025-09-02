import { useQuery } from "@tanstack/react-query";
import { GameId } from "../type-aliases";
import { createClient } from "@/utils/supabase/client";

export const useGameBoard = (gameId: GameId) => {
	return useQuery({
		queryKey: ["game", "board"],
		queryFn: async () => {
			const supabase = createClient();
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
