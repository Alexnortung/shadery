"use client";

import { Button } from "@/components/ui/button";
import { useLobbyStartGame } from "@/lib/lobby/start";
import { LobbyId } from "@/lib/type-aliases";

type Props = {
	lobbyId: LobbyId;
};

const StartGameButton = ({ lobbyId }: Props) => {
	const { mutateAsync: startGame, isPending } = useLobbyStartGame();

	return (
		<Button
			onClick={() => {
				startGame({ lobbyId });
			}}
			disabled={isPending}
		>
			Start game
		</Button>
	);
};

export default StartGameButton;
