import { createClient } from "@/utils/supabase/server";
import { redirect } from "next/navigation";
import Form from "next/form";

export default async function Page() {
	const supabase = await createClient();

	const {
		data: { user },
	} = await supabase.auth.getUser();

	if (!user) {
		return redirect("/sign-in");
	}

	// check if the user is in a lobby

	// If not show a page where they can create a lobby or join one

	const createLobby = async () => {
		"use server";
		// await supabase.rpc("");
		const supabase = await createClient();
		const newLobby = await supabase
			.from("lobbies")
			.insert({})
			.select("id")
			.single();
		const lobbyId = newLobby.data?.id;
		if (!lobbyId) {
			console.error("Failed to create lobby", newLobby.error);
			throw new Error("Failed to create lobby");
		}
		redirect(`/lobby/${lobbyId}`);
	};

	return (
		<div>
			<Form action={createLobby}>
				<button type="submit">Create lobby</button>
			</Form>
		</div>
	);
}
