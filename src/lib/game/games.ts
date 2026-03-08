import { createClient } from "@/utils/supabase/client";
import { useQuery } from "@tanstack/react-query";

export const useGames = () => {
	const supabase = createClient();
	return useQuery({
		queryKey: ["games"],
		queryFn: async () => {
			const resposne = await supabase.from("games").select("*");
			if (resposne.error) {
				throw new Error(resposne.error.message);
			}
			return resposne.data;
		},
	});
};
