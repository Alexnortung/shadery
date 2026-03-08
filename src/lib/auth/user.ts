import { createClient } from "@/utils/supabase/client";
import { queryOptions, useQuery } from "@tanstack/react-query";
import { atom, useAtom } from "jotai";
import { atomWithQuery } from "jotai-tanstack-query";
import { SupabaseContextType, useSupabase } from "../providers/supabase";

export const useUserOptions = (supabase: SupabaseContextType) =>
	queryOptions({
		queryKey: ["auth", "user"],
		queryFn: async ({}) => {
			const supabase = createClient();

			const sessionResponse = await supabase.auth.getSession();
			if (sessionResponse.data.session === null) {
				return null;
			}
			if (sessionResponse.error) {
				throw sessionResponse.error;
			}
			const response = await supabase.auth.getUser();

			if (response.error) {
				throw response.error;
			}

			return response.data.user;
		},
	});

// export const userAtom = atomWithQuery(() => useUserOptions);

export const useUser = () => {
	const supabase = useSupabase();
	return useQuery(useUserOptions(supabase));
};

// export const isLoggedInAtom = atom((get) => {
// 	const query = get(userAtom);
// 	return {
// 		...query,
// 		data: !!query.data,
// 	};
// });

export const useIsLoggedIn = () => {
	// return useAtom(isLoggedInAtom);
	const userQuery = useUser();
	return {
		...userQuery,
		data: !!userQuery.data,
	};
};
