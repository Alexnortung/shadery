import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useSupabase } from "../providers/supabase";
import { GameId } from "../type-aliases";
import { useGameBoard } from "./board";
import { useGame } from "./game";
import { useOnGameTurnChange } from "./subscribers";
import { useCallback } from "react";

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

export const useGamePlayersWithScore = (gameId: GameId) => {
	const supabase = useSupabase();
	const queryClient = useQueryClient();

	useOnGameTurnChange(
		gameId,
		useCallback(() => {
			queryClient.invalidateQueries({
				queryKey: ["game", gameId, "playersWithScore"],
			});
		}, [queryClient]),
	);

	return useQuery({
		queryKey: ["game", gameId, "playersWithScore"],
		queryFn: async () => {
			const response = await supabase
				.from("game_player_with_score")
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

export const useSelfPlayers = (gameId: GameId) => {
	const supabase = useSupabase();

	return useQuery({
		queryKey: ["game", gameId, "selfPlayer"],
		queryFn: async () => {
			const response = await supabase.rpc("user_get_game_player", {
				the_game_id: gameId,
			});

			if (response.error) {
				throw response.error;
			}

			return response.data;
		},
	});
};

export const useIsSelfPlayerTurn = (gameId: GameId) => {
	const { data: selfPlayer } = useSelfPlayers(gameId);
	const { data: game } = useGame(gameId);
	return selfPlayer?.some(
		(player) => player.player_number === game?.current_player_number,
	);
};
