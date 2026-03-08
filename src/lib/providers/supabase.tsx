"use client";

import { createClient } from "@/utils/supabase/client";
import { SupabaseClient } from "@supabase/supabase-js";
import { Database } from "@supabase/types";
import { createContext, FC, useContext, useMemo } from "react";

export type SupabaseContextType = SupabaseClient<Database>;
export const SupabaseContext = createContext<SupabaseContextType | null>(null);

export const useSupabase = () => {
	const context = useContext(SupabaseContext);
	if (!context) {
		throw new Error("useSupabase must be used within a SupabaseProvider");
	}
	return context;
};

export const SupabaseProvider: FC<{
	children: React.ReactNode;
}> = ({ children }) => {
	const client = useMemo(() => createClient(), []);
	return (
		<SupabaseContext.Provider value={client}>
			{children}
		</SupabaseContext.Provider>
	);
};
