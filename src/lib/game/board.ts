import { useQuery, useQueryClient } from "@tanstack/react-query";
import { GameId } from "../type-aliases";
import { useSupabase } from "../providers/supabase";
import { useOnGameTurnChange } from "./subscribers";
import { useCallback } from "react";
import { Database } from "@supabase/types";

export const useGameBoard = (gameId: GameId) => {
	const supabase = useSupabase();
	const queryClient = useQueryClient();
	useOnGameTurnChange(
		gameId,
		useCallback(() => {
			queryClient.invalidateQueries({
				queryKey: ["game", gameId, "board"],
			});
		}, [queryClient, gameId]),
	);
	return useQuery({
		queryKey: ["game", gameId, "board"],
		queryFn: async () => {
			const response = await supabase
				// .from("game_fields")
				.from("game_fields_with_owners")
				.select("*")
				.eq("game_id", gameId);
			if (response.error) {
				throw new Error(response.error.message);
			}

			return response.data as (Database["public"]["Tables"]["game_fields"]["Row"] &
				(typeof response.data)[number])[];
		},
	});
};
