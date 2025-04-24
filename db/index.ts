import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";

async function main() {
	const DATABASE_URL = process.env.DATABASE_URL;
	if (!DATABASE_URL) {
		throw new Error("DATABASE_URL is not defined");
	}
	const client = postgres(DATABASE_URL);
	const db = drizzle({ client, casing: "snake_case" });
}

main();
