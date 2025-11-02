"use client";

import { useLobbyPlayers } from "@/lib/lobby/players";
import { LobbyId } from "@/lib/type-aliases";

type Props = {
	lobbyId: LobbyId;
};

const LobbyPlayers = ({ lobbyId }: Props) => {
	const { data: players, isLoading, error } = useLobbyPlayers({ lobbyId });

	if (isLoading) {
		return <div>Loading players...</div>;
	}

	if (error) {
		return <div>Error loading players: {error.message}</div>;
	}

	return (
		<div>
			<h2>Players</h2>
			<ul>
				{players?.map((player) => (
					<li key={player.id}>
						Player ID: {player.id}, Auth UID:{" "}
						{player.auth_lobby?.auth_uid ?? "Guest"}
					</li>
				))}
			</ul>
		</div>
	);
};

export default LobbyPlayers;
