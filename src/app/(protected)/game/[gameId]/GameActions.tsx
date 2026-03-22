"use client";

import { usePlay } from "@/lib/game/play";
import { GameId } from "@/lib/type-aliases";
import { cn } from "@/lib/utils";
import { getColorClass } from "./lib";
import { useGamePlayerValues, useIsSelfPlayerTurn } from "@/lib/game/players";
import { useGame } from "@/lib/game/game";

type Props = {
	gameId: GameId;
};

const GameActions = ({ gameId }: Props) => {
	const { mutateAsync: play } = usePlay();
	const playableValues = [0, 1, 2, 3, 4, 5];
	const isSelfPlayersTurn = useIsSelfPlayerTurn(gameId);
	const { data: game } = useGame(gameId);
	const values = useGamePlayerValues(gameId);

	return (
		<div className="sticky bottom-0 bg-background/70 backdrop-blur-xl p-4 relative z-10">
			<div className="grid grid-cols-3 gap-2">
				{playableValues.map((value) => (
					<button
						key={value}
						type="button"
						disabled={
							!isSelfPlayersTurn || values.includes(value) || !!game?.ended_at
						}
						className={cn(
							"btn btn-primary min-w-8 min-h-10 md:min-h-16 disabled:cursor-not-allowed disabled:opacity-30",
							getColorClass(value),
						)}
						onClick={() => {
							play({ value, gameId });
						}}
					>
						{/* {value} */}
					</button>
				))}
			</div>
		</div>
	);
};

export default GameActions;
