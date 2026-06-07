"use client";
import { SupabaseProvider } from "@/lib/providers/supabase";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import { ReactNode } from "react";

const queryClient = new QueryClient();

type Props = {
	children: ReactNode;
};

const ClientProviders = ({ children }: Props) => {
	return (
		<SupabaseProvider>
			<QueryClientProvider client={queryClient}>
				<ReactQueryDevtools initialIsOpen={false} />
				{children}
			</QueryClientProvider>
		</SupabaseProvider>
	);
};

export default ClientProviders;
