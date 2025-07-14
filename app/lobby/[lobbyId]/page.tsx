import { createClient } from "@/utils/supabase/server";
import LobbyPlayers from "./LobbyPlayers";
import JoinLobbyButton from "./JoinLobbyButton";

type Props = {
	params: Promise<{
		lobbyId: string;
	}>;
};

export default async function Page({ params: paramsPromise }: Props) {
	const supabase = await createClient();

	const {
		data: { user },
	} = await supabase.auth.getUser();

	const params = await paramsPromise;
	const { lobbyId } = params;

	return (
		<div>
			<JoinLobbyButton lobbyId={lobbyId} />
			<LobbyPlayers lobbyId={lobbyId} />
		</div>
	);
}
