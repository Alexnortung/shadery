import {
	integer,
	pgTable,
	serial,
	smallint,
	uniqueIndex,
} from "drizzle-orm/pg-core";

export const games = pgTable("games", {
	id: serial("id").primaryKey(),
});

export const players = pgTable(
	"players",
	{
		id: serial().primaryKey(),
		gameId: integer().references(() => games.id),
		playerIndex: integer(),
	},
	(table) => [
		uniqueIndex("uq_players_gameId_playerIndex").on(
			table.gameId,
			table.playerIndex,
		),
	],
);

export const fields = pgTable(
	"fields",
	{
		id: serial().primaryKey(),
		gameId: integer().references(() => games.id),
		value: smallint(),
		x: integer(),
		y: integer(),
	},
	(table) => [
		uniqueIndex("uq_fields_gameId_x_y").on(table.gameId, table.x, table.y),
	],
);
