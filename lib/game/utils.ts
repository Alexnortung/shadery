import z from "zod";
import { GameId } from "../type-aliases";

export const gameIdSchema = z.coerce.number().int();

export const parseGameId = (gameId: unknown): GameId | null => {
	const parsed = gameIdSchema.safeParse(gameId);
	if (!parsed.success) {
		return null;
	}
	return parsed.data;
};
