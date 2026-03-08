"use client";

import { useGamePlayers } from "@/lib/game/players";
import { GameId } from "@/lib/type-aliases";

type Props = {
	gameId: GameId;
};

const GamePlayers = ({ gameId }: Props) => {
	const { data: players } = useGamePlayers(gameId);

	console.log("Players:", players);

	return (
		<div className="grid grid-cols-6">
			{players?.map((player) => (
				<div className="border p-2" key={player.id}>
					id: {player.id}; {player.player_number}
				</div>
			))}
		</div>
	);
};

export default GamePlayers;
