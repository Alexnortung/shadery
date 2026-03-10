import {
	queryOptions,
	useMutation,
	useQuery,
	useQueryClient,
} from "@tanstack/react-query";
import { LobbyId } from "../type-aliases";
import { createClient } from "@/utils/supabase/client";
import { useSupabase } from "../providers/supabase";
import { useUser } from "../auth/user";

export const useJoinLobby = () => {
	const queryClient = useQueryClient();
	const supabase = useSupabase();
	return useMutation({
		mutationKey: ["joinLobby"],
		mutationFn: async ({ lobbyId }: { lobbyId: LobbyId }) => {
			console.log("joining", lobbyId);
			const lobbyPlayerIdResponse = await supabase.rpc("user_join_lobby", {
				the_lobby_id: lobbyId,
			});

			if (lobbyPlayerIdResponse.error) {
				throw lobbyPlayerIdResponse.error;
			}

			return lobbyPlayerIdResponse.data;
		},

		onSuccess: (lobbyPlayerId, { lobbyId }) => {
			console.log("Joined lobby", lobbyId, lobbyPlayerId);
			queryClient.invalidateQueries({
				queryKey: ["lobby", lobbyId],
			});
		},
	});
};

const getLobbyConnectionQuery = ({
	lobbyId,
	supabase,
	user,
}: {
	lobbyId: LobbyId;
	supabase: ReturnType<typeof useSupabase>;
	user: ReturnType<typeof useUser>;
}) =>
	queryOptions({
		queryKey: ["lobby", lobbyId, "authLobby", user?.data?.id],
		queryFn: async () => {
			if (!user?.data) {
				throw new Error("User not logged in");
			}
			const response = await supabase
				.from("auth_joined_lobby")
				.select("*")
				.eq("lobby_id", lobbyId)
				.eq("auth_uid", user.data.id)
				.maybeSingle();

			console.log("auth_lobby response", response, lobbyId, user.data.id);

			if (response.error) {
				throw response.error;
			}

			return response.data;
		},
		enabled: !!user,
	});

export const useLobbyConnection = (lobbyId: LobbyId) => {
	const supabase = useSupabase();
	const user = useUser();

	return useQuery(getLobbyConnectionQuery({ lobbyId, supabase, user }));
};

export const useHasJoinedLobby = (lobbyId: LobbyId) => {
	const supabase = useSupabase();
	const user = useUser();

	const lobbyConnectionQuery = useQuery({
		...getLobbyConnectionQuery({ lobbyId, supabase, user }),
		select: (data) => {
			return !!data;
		},
	});

	return lobbyConnectionQuery;
};
