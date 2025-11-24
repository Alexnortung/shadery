import { EventEmitter, Listener } from "tseep";

export type DisconnectFn = () => Promise<void> | void;
export type ConnectFnProps = {
	onEvent: (event: string, ...args: any[]) => void;
};
export type ConnectFn<TData = unknown> = (props: ConnectFnProps) => Promise<{
	disconnectFn: DisconnectFn;
	data?: TData;
}>;

export type ConnectionTrackerConfig<TData = unknown> = {
	connectFn: ConnectFn<TData>;
};

export type DefaultEventMap = {
	[key in string]: Listener;
} & {
	__proto__: never;
};

type ConnectionTrackerEventsMap<EventMap extends DefaultEventMap> = {
	connected: () => void;
	disconnected: () => void;
	error: (error: unknown) => void;
	// event: (event: string, ...args: any[]) => void;
	event: {
		[K in keyof EventMap & string]: (
			event: K,
			...args: Parameters<EventMap[K]>
		) => void;
	}[keyof EventMap & string];
} & {
	// [K in keyof EventMap & string as `event:${K}`]: EventMap[K];
};

type SubscriptionKey = string;

type SubscriptionConfig<EventMap extends DefaultEventMap> = {
	subscriptionKey?: SubscriptionKey;
} & {
	[K in keyof ConnectionTrackerEventsMap<EventMap>]: {
		event: K;
		subscriptionFn: ConnectionTrackerEventsMap<EventMap>[K];
	};
}[keyof ConnectionTrackerEventsMap<EventMap>];

export class ConnectionTracker<
	EventMap extends DefaultEventMap,
	TData = unknown,
> {
	protected ee: EventEmitter<ConnectionTrackerEventsMap<EventMap>>;
	protected disconnectFn: DisconnectFn | null = null;
	protected data: TData | null = null;
	protected error: unknown;
	protected connectionPromise: Promise<void> | null = null;

	protected subscriptions: Map<
		SubscriptionKey | Function,
		{
			[K in keyof ConnectionTrackerEventsMap<EventMap>]: {
				event: K;
				listener: ConnectionTrackerEventsMap<EventMap>[K];
			}[];
		}[keyof ConnectionTrackerEventsMap<EventMap>]
	> = new Map();

	// protected isConnecting = false;
	protected state:
		| "disconnecting"
		| "disconnected"
		| "connecting"
		| "connected" = "disconnected";

	constructor(protected readonly config: ConnectionTrackerConfig<TData>) {
		this.ee = new EventEmitter();
	}

	subscribe<K extends keyof ConnectionTrackerEventsMap<EventMap>>(
		config: SubscriptionConfig<EventMap>,
	): void {
		// this.ee.on(event, listener);
		const key = config.subscriptionKey || config.subscriptionFn;
	}

	// on<K extends keyof ConnectionTrackerEventsMap<EventMap>>(
	// 	event: K,
	// 	listener: ConnectionTrackerEventsMap<EventMap>[K],
	// ): void {
	// 	this.ee.on(event, listener);
	// }
	//
	// off<K extends keyof ConnectionTrackerEventsMap<EventMap>>(
	// 	event: K,
	// 	listener: ConnectionTrackerEventsMap<EventMap>[K],
	// ): void {
	// 	this.ee.off(event, listener);
	// }

	connect() {
		if (this.connectionPromise) {
			return this.connectionPromise;
		}
		if (this.state === "connected" || this.state === "connecting") {
			return;
		}
		this.state = "connecting";
		const promise = new Promise<void>(async (resolve, reject) => {
			try {
				const connectResponse = await this.config.connectFn({
					onEvent: <Event extends keyof EventMap>(
						event: Event,
						...args: Parameters<EventMap[Event]>
					) => {
						// this.ee.emit(`event:${event}` as any, ...args);
						// @ts-expect-error TS cannot infer that the types should be compatible here
						this.ee.emit("event", event, ...args);
					},
				});
				this.disconnectFn = connectResponse.disconnectFn;
				this.data = connectResponse.data ?? null;
				this.ee.emit("connected");
			} catch (error) {
				// TODO: retry

				this.error = error;
				this.connectionPromise = null;
				this.state = "disconnected";
				this.ee.emit("error", error);
			}
			this.connectionPromise = null;

			resolve();
		});

		this.connectionPromise = promise;

		return promise;
	}

	async disconnect() {
		if (this.state === "disconnected" || this.state === "disconnecting") {
			return;
		}
		this.connectionPromise = null;
		try {
			await this.disconnectFn?.();
			this.disconnectFn = null;
			this.ee.emit("disconnected");
		} catch (error) {
			// TODO: retry?
			// TODO: how do we handle disconnect errors?
			this.error = error;
			this.ee.emit("error", error);
		}
	}
}
