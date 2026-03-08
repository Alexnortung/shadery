import { useMutation, useQueryClient } from "@tanstack/react-query";
import { LobbyId } from "../type-aliases";
import { createClient } from "@/utils/supabase/client";
import { useSupabase } from "../providers/supabase";

export const useLeaveLobby = () => {
	const queryClient = useQueryClient();
	const supabase = useSupabase();
	return useMutation({
		mutationKey: ["leaveLobby"],
		mutationFn: async ({ lobbyId }: { lobbyId: LobbyId }) => {
			console.log(`leaving lobby ${lobbyId}`);
			const response = await supabase.rpc("user_leave_lobby", {
				the_lobby_id: lobbyId,
			});

			if (response.error) {
				throw response.error;
			}
		},

		onSuccess: (_, { lobbyId }) => {
			console.log("Left lobby", lobbyId);
			queryClient.invalidateQueries({
				queryKey: ["lobby", lobbyId],
			});
		},
	});
};
