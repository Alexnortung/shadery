import { useQuery } from "@tanstack/react-query";
import { useSupabase } from "../providers/supabase";
import { GameId } from "../type-aliases";
import { useGameBoard } from "./board";

export const useGamePlayers = (gameId: GameId) => {
	const supabase = useSupabase();

	return useQuery({
		queryKey: ["game", gameId, "players"],
		queryFn: async () => {
			const response = await supabase
				.from("game_players")
				.select("*")
				.eq("game_id", gameId);
			if (response.error) {
				throw new Error(response.error.message);
			}

			return response.data;
		},
	});
};

export const useGamePlayerValues = (gameId: GameId) => {
	const { data: players } = useGamePlayers(gameId);
	const { data: gameBoard } = useGameBoard(gameId);
	return (
		players?.map((player) => {
			const playerField = gameBoard?.find(
				(field) =>
					player.position_x === field.x && player.position_y === field.y,
			);
			return playerField?.field_value;
		}) ?? []
	);
};
