import { createContext, useContext, useEffect, useRef, useState } from "react";
import { ConnectionManager } from "./manager";
import { ConnectionTrackerConfig, SubscriptionConfig } from "./types";

export const ConnectionManagerContext = createContext<ConnectionManager | null>(
	null,
);

export const ConnectionManagerProvider = ({
	children,
	manager,
}: {
	children: React.ReactNode;
	manager: ConnectionManager;
}) => {
	return (
		<ConnectionManagerContext.Provider value={manager}>
			{children}
		</ConnectionManagerContext.Provider>
	);
};

export const useConnectionManager = (): ConnectionManager => {
	const manager = useContext(ConnectionManagerContext);
	if (!manager) {
		throw new Error(
			"useConnectionManager must be used within a ConnectionManagerProvider",
		);
	}
	return manager;
};

export const useConnectionSubscription = (
	connectionConfig: ConnectionTrackerConfig,
	subscriptionConfig: SubscriptionConfig,
) => {
	const manager = useConnectionManager();

	useEffect(() => {
		const { unsubscribe } = manager.subscribeToConnection(
			connectionConfig,
			subscriptionConfig,
		);
		return () => {
			console.log("Unsubscribing from connection subscription");
			unsubscribe();
		};
	}, [manager, connectionConfig, subscriptionConfig]);
};

export const useAllConnectionTrackers = () => {
	const manager = useConnectionManager();
	const [trackers, setTrackers] = useState(() =>
		Array.from(manager.getAllConnectionTrackers()),
	);
	useEffect(() => {
		const onTrackerAdded = () => {
			const newTrackers = Array.from(manager.getAllConnectionTrackers());
			console.log("Tracker added, updating trackers list", newTrackers);
			setTrackers(newTrackers);
		};
		const onTrackerRemoved = () => {
			const newTrackers = Array.from(manager.getAllConnectionTrackers());
			console.log("Tracker removed, updating trackers list", newTrackers);
			setTrackers(newTrackers);
		};
		const onTrackerAddedForGc = () => {
			const newTrackers = Array.from(manager.getAllConnectionTrackers());
			console.log("Tracker added for GC, updating trackers list", newTrackers);
			setTrackers(newTrackers);
		};

		manager.on("trackerAddedForGc", onTrackerAddedForGc);
		manager.on("trackerGced", onTrackerRemoved);
		manager.on("trackerAdded", onTrackerAdded);

		return () => {
			manager.off("trackerAddedForGc", onTrackerAddedForGc);
			manager.off("trackerGced", onTrackerRemoved);
			manager.off("trackerAdded", onTrackerAdded);
		};
	}, [manager]);

	return trackers;
};
