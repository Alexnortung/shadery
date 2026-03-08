import { useEffect } from "react";
import { GameId } from "../type-aliases";
import { useSupabase } from "../providers/supabase";
import { useQueryClient } from "@tanstack/react-query";

export const useSubscribeToGameTurnChange = (
	gameId: GameId,
	subscriber: () => void,
) => {
	const supabase = useSupabase();

	useEffect(() => {
		const channel = supabase
			.channel("table-db-changes")
			.on(
				"postgres_changes",
				{
					event: "*",
					schema: "public",
					table: "games",
					filter: `id=eq.${gameId}`,
				},
				(payload) => {
					subscriber();
				},
			)
			.subscribe();

		// console.log("Subscribed to game updates", gameId);

		return () => {
			// console.log("Unsubscribing from game updates", gameId);
			supabase.removeChannel(channel);
		};
	}, [gameId, supabase]);
};
