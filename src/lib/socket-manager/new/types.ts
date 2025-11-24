export type ConnectionKey = string;

export type ConnectFnProps = {
	onConnected: () => void;
	onDisconnected: () => void;
	onMessage: (data: unknown) => void;
};

export type DisconnectFn = () => void;
export type ConnectFn = (props: ConnectFnProps) => {
	disconnectFn: DisconnectFn;
	sendMessage?: (...args: unknown[]) => unknown;
};

export type ConnectionTrackerConfig = {
	key: ConnectionKey;
	connectFn: ConnectFn;
};

export type SubscriptionKey = string;
export type SubscriptionListener = (message: unknown) => void;

export type SubscriptionConfig = {
	key: SubscriptionKey;
	listener: SubscriptionListener;
};

export interface IConnectionTracker {
	connect(): void;
	disconnect(): void;
	// TODO: send message is not implemented for first iteration
	// sendMessage: (...args: unknown[]) => unknown;

	subscribe(config: SubscriptionConfig): () => void;

	hasSubscribers(): boolean;
}

export interface IConnectionManager {
	getConnectionTracker(key: ConnectionKey): IConnectionTracker | undefined;
	// setupConnection: (config: ConnectionTrackerConfig) => ConnectionTracker;
	subscribeToConnection(
		connectionConfig: ConnectionTrackerConfig,
		subscriptionConfig: SubscriptionConfig,
	): {
		unsubscribe: () => void;
		connectionTracker: IConnectionTracker;
	};
}
