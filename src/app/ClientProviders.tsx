"use client";
import { SupabaseProvider } from "@/lib/providers/supabase";
import { ConnectionManagerDevtools } from "@/lib/socket-manager/new/devtools";
import { ConnectionManagerProvider } from "@/lib/socket-manager/new/hooks";
import { ConnectionManager } from "@/lib/socket-manager/new/manager";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import { ReactNode } from "react";

const queryClient = new QueryClient();
const connectionManager = new ConnectionManager();

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
