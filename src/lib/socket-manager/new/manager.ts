import { EventEmitter } from "tseep";
import { ConnectionTracker } from "./connection-tracker";
import {
	ConnectionKey,
	ConnectionTrackerConfig,
	IConnectionManager,
	IConnectionTracker,
	SubscriptionConfig,
} from "./types";

type EventMap = {
	trackerAdded: (key: ConnectionKey, tracker: IConnectionTracker) => void;
	trackerAddedForGc: (key: ConnectionKey, tracker: IConnectionTracker) => void;
	trackerGced: (key: ConnectionKey, tracker: IConnectionTracker) => void;
	gcScheduled: () => void;
	gc: () => void;
	gcDone: () => void;
};

export class ConnectionManager implements IConnectionManager {
	private readonly trackers: Map<ConnectionKey, IConnectionTracker> = new Map();

	private readonly gcMap: Map<ConnectionKey, number> = new Map();
	private gcTimout: NodeJS.Timeout | null = null;

	private eventEmitter: EventEmitter<EventMap> = new EventEmitter();

	getAllConnectionTrackers(): ReadonlyMap<ConnectionKey, IConnectionTracker> {
		return this.trackers;
	}

	getConnectionTracker(key: ConnectionKey) {
		return this.trackers.get(key);
	}

	on<EventKey extends keyof EventMap>(
		event: EventKey,
		listener: EventMap[EventKey],
	) {
		this.eventEmitter.on(event, listener);
	}

	off<EventKey extends keyof EventMap>(
		event: EventKey,
		listener: EventMap[EventKey],
	) {
		this.eventEmitter.off(event, listener);
	}

	private scheduleGc() {
		if (this.gcTimout) {
			return;
		}
		this.eventEmitter.emit("gcScheduled");
		this.gcTimout = setTimeout(() => {
			this.gcTimout = null;
			this.runGc();
			if (this.gcMap.size > 0) {
				// reschedule until all idle trackers are cleaned up
				this.scheduleGc();
			}
		}, 6 * 1000); // Should be just longer than the gc threshold
	}

	private runGc() {
		const now = Date.now();
		const gcThreshold = 5 * 1000; // 5 seconds
		this.eventEmitter.emit("gc");
		for (const [key, timestamp] of this.gcMap.entries()) {
			const gcTimestamp = timestamp + gcThreshold;
			if (gcTimestamp > now) {
				continue;
			}

			const tracker = this.trackers.get(key);
			this.gcMap.delete(key);
			if (!tracker) {
				continue;
			}
			if (tracker.hasSubscribers()) {
				continue;
			}
			tracker.disconnect();
			this.trackers.delete(key);
			this.eventEmitter.emit("trackerGced", key, tracker);
		}
		this.eventEmitter.emit("gcDone");
	}

	private getOrCreateConnectionTracker(
		config: ConnectionTrackerConfig,
	): IConnectionTracker {
		const key = config.key;
		const tracker = this.trackers.get(key);
		if (tracker) {
			return tracker;
		}
		const newTracker = new ConnectionTracker(config);
		this.trackers.set(key, newTracker);
		return newTracker;
	}

	private onUnsubscribeTracker(key: ConnectionKey) {
		const tracker = this.trackers.get(key);
		if (tracker && !tracker.hasSubscribers()) {
			this.gcMap.set(key, Date.now());
			this.eventEmitter.emit("trackerAddedForGc", key, tracker);
			this.scheduleGc();
		}
	}

	subscribeToConnection(
		connectionConfig: ConnectionTrackerConfig,
		subscriptionConfig: SubscriptionConfig,
	) {
		const connectionTracker =
			this.getOrCreateConnectionTracker(connectionConfig);
		this.gcMap.delete(connectionConfig.key);
		connectionTracker.connect();
		const trackerUnsubscribe = connectionTracker.subscribe(subscriptionConfig);
		let unsubscribed = false;
		const unsubscribe = () => {
			if (unsubscribed) {
				return;
			}
			unsubscribed = true;
			trackerUnsubscribe();
			this.onUnsubscribeTracker(connectionConfig.key);
		};
		return {
			unsubscribe,
			connectionTracker,
		};
	}
}
