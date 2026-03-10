"use client";

import { useGame } from "@/lib/game/game";
import { useGamePlayersWithScore } from "@/lib/game/players";
import { GameId } from "@/lib/type-aliases";

type Props = {
	gameId: GameId;
};

const EndGameModal = ({ gameId }: Props) => {
	const { data: gameInfo } = useGame(gameId);
	const { data: playerScores } = useGamePlayersWithScore(gameId, {
		select: (playerScores) =>
			playerScores.sort((a, b) => (b.score ?? 0) - (a.score ?? 0)),
	});

	const isGameEnded = !!gameInfo?.ended_at;

	if (!isGameEnded) {
		return null;
	}

	return (
		<div className="absolute z-10 top-0 left-0 w-full h-full bg-black bg-opacity-50 flex flex-col justify-center items-center">
			<div className="bg-background p-8 rounded shadow-lg">
				<h2 className="text-2xl font-bold mb-4">Game Over</h2>
				<div className="mb-4">
					{playerScores?.map((player) => (
						<div key={player.id}>
							Player {player.player_number}: {player.score} points
						</div>
					))}
				</div>
			</div>
		</div>
	);
};

export default EndGameModal;
