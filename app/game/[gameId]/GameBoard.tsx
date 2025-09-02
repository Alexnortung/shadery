import { useGameBoard } from "@/lib/game/board";
import { GameId } from "@/lib/type-aliases";

type Props = {
	gameId: GameId;
};

const GameBoard = ({ gameId }: Props) => {
	const { data } = useGameBoard(gameId);
	const minX =
		data?.reduce((min, field) => Math.min(min, field.x), Infinity) ?? 0;
	const maxX =
		data?.reduce((max, field) => Math.max(max, field.x), -Infinity) ?? 0;
	const minY =
		data?.reduce((min, field) => Math.min(min, field.y), Infinity) ?? 0;
	const maxY =
		data?.reduce((max, field) => Math.max(max, field.y), -Infinity) ?? 0;

	return (
		<div
			className="grid"
			style={{
				gridTemplateRows: `repeat(${maxY - minY + 1}, 1fr)`,
				gridTemplateColumns: `repeat(${maxX - minX + 1}, 1fr)`,
			}}
		>
			{data?.map((field) => (
				<div
					key={field.id}
					className="field"
					style={{
						gridRowStart: field.y - minY + 1,
						gridColumnStart: field.x - minX + 1,
					}}
				>
					{field.field_value}
				</div>
			))}
		</div>
	);
};

export default GameBoard;
