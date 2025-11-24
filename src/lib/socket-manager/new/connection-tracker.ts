import { KeyedEventEmitter } from "../keyed-ee";
import {
	ConnectionTrackerConfig,
	DisconnectFn,
	IConnectionTracker,
	SubscriptionConfig,
} from "./types";

export class ConnectionTracker implements IConnectionTracker {
	private disconnectFn: DisconnectFn | null = null;
	private state: "connected" | "connecting" | "disconnected" | "disconnecting" =
		"disconnected";

	private eventEmitter: KeyedEventEmitter = new KeyedEventEmitter();

	constructor(private readonly config: ConnectionTrackerConfig) {}

	connect() {
		const response = this.config.connectFn({
			onMessage: (message) => {
				this.eventEmitter.emitAll(message);
			},
			onConnected: () => {},
			onDisconnected: () => {},
		});
		this.disconnectFn = response.disconnectFn;
	}

	disconnect() {
		if (this.state === "disconnected" || this.state === "disconnecting") {
			return;
		}
		this.state = "disconnecting";
		if (this.disconnectFn) {
			this.disconnectFn();
			this.disconnectFn = null;
		}
		this.state = "disconnected";
	}

	subscribe(config: SubscriptionConfig) {
		this.eventEmitter.on(config.key, config.listener);

		let unsubscribed = false;
		return () => {
			if (unsubscribed) {
				return;
			}
			this.eventEmitter.off(config.key);
			unsubscribed = true;
		};
	}

	hasSubscribers() {
		return this.eventEmitter.hasListeners();
	}
}
