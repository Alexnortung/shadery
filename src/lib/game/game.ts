import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useSupabase } from "../providers/supabase";
import { GameId } from "../type-aliases";
import { useOnGameTurnChange } from "./subscribers";
import { useCallback } from "react";

export const useGame = (gameId: GameId) => {
	const supabase = useSupabase();
	const queryClient = useQueryClient();

	useOnGameTurnChange(
		gameId,
		useCallback(() => {
			queryClient.invalidateQueries({
				queryKey: ["game", gameId, "info"],
			});
		}, []),
	);

	return useQuery({
		queryKey: ["game", gameId, "info"],
		queryFn: async () => {
			const response = await supabase
				.from("games")
				.select("*")
				.eq("id", gameId)
				.single();
			if (response.error) {
				throw new Error(response.error.message);
			}

			return response.data;
		},
	});
};

export const useGameCurrentPlayer = (gameId: GameId) => {
	const { data: game } = useGame(gameId);
	// TODO: use select
	return game?.current_player_number;
};
