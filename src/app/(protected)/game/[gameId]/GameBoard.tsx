"use client";

import { useGameBoard } from "@/lib/game/board";
import { useGames } from "@/lib/game/games";
import { useSupabase } from "@/lib/providers/supabase";
import { GameId } from "@/lib/type-aliases";
import { cn } from "@/lib/utils";
import { createClient } from "@/utils/supabase/client";
import { useQueryClient } from "@tanstack/react-query";
import { useEffect } from "react";
import { getColorClass } from "./lib";
import { useGameCurrentPlayer } from "@/lib/game/game";
import { useGamePlayers, useSelfPlayers } from "@/lib/game/players";

import "./game-board.css";

type Props = {
	gameId: GameId;
};

const GameBoard = ({ gameId }: Props) => {
	const { data } = useGameBoard(gameId);
	const { data: selfPlayers } = useSelfPlayers(gameId);
	const currentPlayerNumber = useGameCurrentPlayer(gameId);

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
			className={cn("grid")}
			style={{
				gridTemplateRows: `repeat(${maxY - minY + 1}, 1.25em)`,
				gridTemplateColumns: `repeat(${maxX - minX + 1}, 1.25em)`,
				fontSize: "min(1.2vh,2.6vw)",
			}}
		>
			{data?.map((field) => {
				const isSelfPlayerField = selfPlayers?.some(
					(player) =>
						player.position_x === field.x && player.position_y === field.y,
				);
				const isCurrentPlayerField =
					currentPlayerNumber !== undefined &&
					field.owner_player_number === currentPlayerNumber;
				return (
					<div
						key={field.id}
						className={cn(
							"field size-full relative",
							"flex items-center justify-center text-center",
							"relative z-5",
							// isCurrentPlayerField && "z-10 outline outline-yellow-500",
							field.field_value !== null && getColorClass(field.field_value),
							// isCurrentPlayerField && "animate-pulse",
							isCurrentPlayerField && "game-board__field--active",
						)}
						style={{
							gridRowStart: field.y - minY + 1,
							gridColumnStart: field.x - minX + 1,
						}}
					>
						{isSelfPlayerField && "•"}
						{/* {field.field_value} */}
					</div>
				);
			})}
		</div>
	);
};

export default GameBoard;
