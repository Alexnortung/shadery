"use client";

import { Button } from "@/components/ui/button";
import JoinLobbyButton from "./JoinLobbyButton";
import { LobbyId } from "@/lib/type-aliases";
import LeaveLobbyButton from "./LeaveLobbyButton";
import StartGameButton from "./StartGameButton";

type Props = {
	lobbyId: LobbyId;
};

const LobbyActions = ({ lobbyId }: Props) => {
	const hasJoinedLobby = false;

	return (
		<div className="flex flex-col gap-2">
			<StartGameButton lobbyId={lobbyId} />
			<LeaveLobbyButton lobbyId={lobbyId} />
		</div>
	);
};

export default LobbyActions;
