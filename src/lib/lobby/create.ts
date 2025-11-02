import { createClient } from "@/utils/supabase/client";
import { useMutation, useQuery } from "@tanstack/react-query";

export const useCreateLobby = () => {
	return useMutation({
		mutationKey: ["createLobby"],
		mutationFn: async () => {
			console.log("creating lobby");
			const supabase = createClient();

			const lobbyIdResponse = await supabase.rpc("user_create_lobby");
			if (lobbyIdResponse.error) {
				throw lobbyIdResponse.error;
			}

			return lobbyIdResponse.data;
		},
	});
};
