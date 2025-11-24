import { createContext, useContext, useEffect } from "react";
import { SocketManager } from "./socket-manager";

export const SocketManagerContext = createContext<SocketManager | null>(null);

export const useSocketManager = () => {
	const socketManager = useContext(SocketManagerContext);
	if (!socketManager) {
		throw new Error(
			"useSocketManager must be used within a SocketManagerProvider",
		);
	}
	return socketManager;
};

type ConnectionConfig = {
	connectionKey?: string[];
};

// export const useConnection = (props: {
// 	connectionKey: string[];
// }) => {
// 	const socketManager = useSocketManager();
// 	// Get existing connection by key
// 	// If not exists, create new connection using connectFn
// 	//   Add the connection to the connection manager
// 	// observe the connection for changes - such as disconnection
// };
//

type SubscriptionConfig = {
	subscriptionKey?: string[];
	enabled?: boolean;
};

export const useSubscription = (
	connectionConfig: ConnectionConfig,
	subscriptionConfig: SubscriptionConfig,
) => {
	const socketManager = useSocketManager();

	useEffect(() => {
		if (!subscriptionConfig.enabled) {
			return;
		}
		socketManager.subscribe({});
	}, [socketManager, subscriptionConfig.enabled]);
};
