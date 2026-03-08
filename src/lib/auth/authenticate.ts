import { createClient } from "@/utils/supabase/client";
import { useMutation, useQueryClient } from "@tanstack/react-query";

const AUTHENTICATE_KEY = "authenticate";

export const useSignInAsGuest = () => {
	const queryClient = useQueryClient();
	return useMutation({
		mutationKey: [AUTHENTICATE_KEY, "sign-in-guest"],
		mutationFn: async () => {
			const supabase = createClient();
			const response = await supabase.auth.signInAnonymously();
			if (response.error) {
				throw response.error;
			}
			return response.data;
		},

		onSettled: (_data, _error, _variables, context) => {
			queryClient.invalidateQueries({ queryKey: ["auth"] });
		},
	});
};

export const useSignOut = () => {
	const queryClient = useQueryClient();
	return useMutation({
		mutationKey: [AUTHENTICATE_KEY, "sign-out"],
		mutationFn: async () => {
			const supabase = createClient();
			const response = await supabase.auth.signOut();
			if (response.error) {
				throw response.error;
			}
		},
		onSettled: (_data, _error, _variables, context) => {
			queryClient.invalidateQueries({ queryKey: ["auth"] });
		},
	});
};

export const useIsAuthenticating = () => {
	// const { isPending: guestPending } = useSignInAsGuest();
	const { isPending } = useMutation({
		mutationKey: [AUTHENTICATE_KEY],
	});

	return isPending;
};
