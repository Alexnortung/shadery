import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { LobbyId } from "../type-aliases";
import { createClient } from "@/utils/supabase/client";
import { redirect } from "next/navigation";
import { useEffect } from "react";

export const useLobbyStartGame = () => {
	const queryClient = useQueryClient();
	return useMutation({
		mutationKey: ["lobbyStartGame"],
		mutationFn: async ({ lobbyId }: { lobbyId: LobbyId }) => {
			const supabase = createClient();
			const response = await supabase.rpc("user_lobby_start_game", {
				the_lobby_id: lobbyId,
			});

			if (response.error) {
				throw response.error;
			}

			const gameId = response.data;

			return gameId;
		},

		onSuccess: (gameId, { lobbyId }) => {
			console.log("Lobby game started", lobbyId, gameId);
			queryClient.invalidateQueries({
				queryKey: ["lobby", lobbyId],
			});
			// redirect(`/game/${gameId}`);
		},
	});
};

export const useLobbyGame = (lobbyId: LobbyId) => {
	return useQuery({
		queryKey: ["lobbyGame", lobbyId],
		queryFn: async () => {
			const supabase = createClient();
			const response = await supabase
				.from("lobby_game")
				.select("*")
				.eq("lobby_id", lobbyId)
				.single();

			if (response.error) {
				throw response.error;
			}

			return response.data;
		},
		refetchOnWindowFocus: false,
	});
};

export const useOnLobbyStarted = (lobbyId: LobbyId) => {
	useEffect(() => {
		console.log("Setting up lobby started listener for", lobbyId);
		const supabase = createClient();
		const channel = supabase
			.channel(`game_started:lobbyId=eq.${lobbyId}`)
			.on(
				"postgres_changes",
				{
					event: "INSERT",
					schema: "public",
					table: "lobby_game",
					filter: `lobby_id=eq.${lobbyId}`,
				},
				(payload) => {
					const gameId = payload.new.game_id;
					console.log("Received lobby started event", payload);
					console.log("Lobby started, redirecting to game", gameId);
					redirect(`/game/${gameId}`);
				},
			)
			.subscribe();

		return () => {
			supabase.removeChannel(channel);
		};
	}, [lobbyId]);
};
