"use client";

import { LobbyId } from "@/lib/type-aliases";
import JoinLobbyButton from "./JoinLobbyButton";
import { useHasJoinedLobby } from "@/lib/lobby/join";

type Props = {
	lobbyId: LobbyId;
};

const GameSettingsContainer = ({ lobbyId }: Props) => {
	const { data: hasJoinedLobby } = useHasJoinedLobby(lobbyId);

	if (!hasJoinedLobby) {
		return (
			<div className="w-full h-full flex justify-center items-center">
				<JoinLobbyButton lobbyId={lobbyId} />
			</div>
		);
	}

	return (
		<div>
			<div>Nothing here yet</div>
		</div>
	);
};

export default GameSettingsContainer;
