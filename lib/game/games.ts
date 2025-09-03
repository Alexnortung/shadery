import { createClient } from "@/utils/supabase/client";
import { useQuery } from "@tanstack/react-query";

export const useGames = () => {
	return useQuery({
		queryKey: ["games"],
		queryFn: async () => {
			const supabase = createClient();
			const resposne = await supabase.from("games").select("*");
			if (resposne.error) {
				throw new Error(resposne.error.message);
			}
			return resposne.data;
		},
	});
};
