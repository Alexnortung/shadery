import { useAllConnectionTrackers, useConnectionManager } from "../hooks";

export const ConnectionManagerDevtools = () => {
	const connectionTrackers = useAllConnectionTrackers();

	return (
		<div className="absolute bottom-0 left-0 right-0 bg-white dark:bg-black">
			<h2>Connection manager devtools</h2>

			<div>
				{connectionTrackers.map(([key, tracker]) => (
					<div key={key}>{key}</div>
				))}
			</div>
		</div>
	);
};
