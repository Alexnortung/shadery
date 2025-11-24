import { ConnectFn, ConnectionTracker, DefaultEventMap } from "./connection";

type ConnectionKey = string;
type SubscriptionKey = string;

type ConnectionConfig = {
	connectionKey: ConnectionKey;
	connectFn: ConnectFn;
};

export class SocketManager<EventMap extends DefaultEventMap = DefaultEventMap> {
	protected connections: Map<ConnectionKey, ConnectionTracker<EventMap>> =
		new Map();

	public getConnection(
		key: ConnectionKey,
	): ConnectionTracker<EventMap> | undefined {
		return this.connections.get(key);
	}

	// private ensureConnection(connectionConfig: ConnectionConfig) {
	// 	let connection = this.getConnection(connectionConfig.connectionKey);
	// 	if (!connection) {
	// 		connection = new ConnectionTracker({
	// 			connectFn: connectionConfig.connectFn,
	// 		});
	// 		this.connections.set(connectionConfig.connectionKey, connection);
	// 	}
	// 	return connection;
	// }

	public async subscribe<Event extends keyof EventMap>(
		// TODO: types
		connectionConfig: {
			connectionKey: ConnectionKey;
			connectFn: ConnectFn;
		},
		subscriptionConfig: {
			subscriptionKey: SubscriptionKey;
			eventName: Event;
			subscriptionFn: EventMap[Event];
		},
	) {
		let connection = this.getConnection(connectionConfig.connectionKey);
		if (!connection) {
			connection = new ConnectionTracker({
				connectFn: connectionConfig.connectFn,
			});
			this.connections.set(connectionConfig.connectionKey, connection);
		}
		await connection.connect();

		// connection.on("event", () => {
		// 	subscriptionConfig.subscriptionFn();
		// });

		// connection.addSubscription(subscriptionConfig.subscriptionKey);
	}
}
