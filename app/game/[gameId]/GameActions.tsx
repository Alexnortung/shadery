"use client";

import { usePlay } from "@/lib/game/play";
import { GameId } from "@/lib/type-aliases";

type Props = {
	gameId: GameId;
};

const GameActions = ({ gameId }: Props) => {
	const { mutateAsync: play } = usePlay();
	const playableValues = [0, 1, 2, 3, 4, 5];

	return (
		<div>
			<div className="grid grid-cols-3">
				{playableValues.map((value) => (
					<button
						key={value}
						type="button"
						className="btn btn-primary m-2"
						onClick={() => {
							play({ value, gameId });
						}}
					>
						{value}
					</button>
				))}
			</div>
		</div>
	);
};

export default GameActions;
