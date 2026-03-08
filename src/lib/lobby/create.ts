import { createClient } from "@/utils/supabase/client";
import { useMutation, useQuery } from "@tanstack/react-query";
import { useSupabase } from "../providers/supabase";

export const useCreateLobby = () => {
	const supabase = useSupabase();
	return useMutation({
		mutationKey: ["createLobby"],
		mutationFn: async () => {
			const lobbyIdResponse = await supabase.rpc("user_create_lobby");
			if (lobbyIdResponse.error) {
				throw lobbyIdResponse.error;
			}

			return lobbyIdResponse.data;
		},
	});
};
