"use client";

import { useGameBoard } from "@/lib/game/board";
import { useGames } from "@/lib/game/games";
import { GameId } from "@/lib/type-aliases";
import { createClient } from "@/utils/supabase/client";
import { useQueryClient } from "@tanstack/react-query";
import { useEffect } from "react";

type Props = {
	gameId: GameId;
};

const GameBoard = ({ gameId }: Props) => {
	const queryClient = useQueryClient();
	useEffect(() => {
		const supabase = createClient();
		const channel = supabase
			.channel("table-db-changes")
			.on(
				"postgres_changes",
				{
					event: "*",
					schema: "public",
					table: "games",
					filter: `id=eq.${gameId}`,
				},
				(payload) => {
					// Invalidate game board
					queryClient.invalidateQueries({
						queryKey: ["game", gameId],
					});
				},
			)
			.subscribe();

		console.log("Subscribed to game updates", gameId);

		return () => {
			console.log("Unsubscribing from game updates", gameId);
			supabase.removeChannel(channel);
		};
	}, [gameId, queryClient]);

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
					className="field size-5"
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
