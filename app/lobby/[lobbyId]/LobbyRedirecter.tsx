"use client";

import { useLobbyGame, useOnLobbyStarted } from "@/lib/lobby/start";
import { LobbyId } from "@/lib/type-aliases";

type Props = {
	lobbyId: LobbyId;
};

const LobbyRedirecter = ({ lobbyId }: Props) => {
	useOnLobbyStarted(lobbyId);

	// const query = useLobbyGame(lobbyId);

	return null;
};

export default LobbyRedirecter;
