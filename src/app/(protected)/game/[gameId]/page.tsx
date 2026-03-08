import { notFound } from "next/navigation";
import GameBoard from "./GameBoard";
import { parseGameId } from "@/lib/game/utils";
import GameActions from "./GameActions";
import GamePlayers from "./GamePlayers";

type Props = {
	params: Promise<{
		gameId: string;
	}>;
};

export default async function Page({ params: paramsPromise }: Props) {
	const params = await paramsPromise;

	const gameId = parseGameId(params.gameId);
	if (!gameId) {
		notFound();
	}

	return (
		<div>
			Players:
			<br />
			<GamePlayers gameId={gameId} />
			<br />
			<GameBoard gameId={gameId} />
			<GameActions gameId={gameId} />
		</div>
	);
}
