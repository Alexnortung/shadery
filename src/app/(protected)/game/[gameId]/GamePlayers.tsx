"use client";

import { useGame, useGameCurrentPlayer } from "@/lib/game/game";
import { useGamePlayers, useGamePlayersWithScore } from "@/lib/game/players";
import { GameId } from "@/lib/type-aliases";
import { cn } from "@/lib/utils";

type Props = {
	gameId: GameId;
};

const GamePlayers = ({ gameId }: Props) => {
	const { data: players } = useGamePlayers(gameId);

	return (
		<div className="flex flex-wrap gap-8">
			{players?.map((player) => (
				<PlayerBox key={player.id} gameId={gameId} player={player} />
			))}
		</div>
	);
};

const PlayerBox = ({
	gameId,
	player,
}: {
	gameId: GameId;
	player: { id: number; player_number: number };
}) => {
	const currentPlayer = useGameCurrentPlayer(gameId);
	const { data: playersWithScore } = useGamePlayersWithScore(gameId);
	const playerWithScore = playersWithScore?.find((p) => p.id === player.id);
	const score = playerWithScore?.score;
	const { data: game } = useGame(gameId);
	const gameSize = game ? game.size_x * game.size_y : null;
	const scorePercentage =
		typeof score === "number" && gameSize
			? ((score / gameSize) * 100).toFixed(0)
			: null;

	return (
		<div
			className={cn(
				"flex flex-col",
				"border p-2",
				"min-w-[120px]",
				currentPlayer === player.player_number &&
					"shadow-lg shadow-green-500/50",
			)}
			key={player.id}
		>
			<span>
				Score: {playerWithScore?.score} ({scorePercentage ?? "?"}%)
			</span>
			<span className="text-xs text-gray-500">
				Player {player.player_number}
			</span>
		</div>
	);
};

export default GamePlayers;
