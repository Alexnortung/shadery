"use client";

import { useLobbyStartGame } from "@/lib/lobby/start";
import { LobbyId } from "@/lib/type-aliases";

type Props = {
	lobbyId: LobbyId;
};

const StartGameButton = ({ lobbyId }: Props) => {
	const { mutateAsync: startGame, isPending } = useLobbyStartGame();

	return (
		<button
			type="button"
			onClick={() => {
				startGame({ lobbyId });
			}}
			disabled={isPending}
		>
			Start game
		</button>
	);
};

export default StartGameButton;
