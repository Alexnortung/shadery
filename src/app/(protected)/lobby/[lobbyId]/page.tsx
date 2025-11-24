import { createClient } from "@/utils/supabase/server";
import LobbyPlayers from "./LobbyPlayers";
import JoinLobbyButton from "./JoinLobbyButton";
import LeaveLobbyButton from "./LeaveLobbyButton";
import StartGameButton from "./StartGameButton";
import LobbyRedirecter from "./LobbyRedirecter";
import Container from "@/components/ui/container";
import LobbyActions from "./LobbyActions";
import GameSettingsContainer from "./GameSettingsContainer";

type Props = {
	params: Promise<{
		lobbyId: string;
	}>;
};

export default async function Page({ params: paramsPromise }: Props) {
	// const supabase = await createClient();
	//
	// const {
	// 	data: { user },
	// } = await supabase.auth.getUser();

	const params = await paramsPromise;
	const { lobbyId } = params;

	return (
		<div className="grid md:grid-cols-2 gap-4">
			<LobbyRedirecter lobbyId={lobbyId} />

			<Container>
				<GameSettingsContainer lobbyId={lobbyId} />
			</Container>
			<div className="flex flex-col gap-4">
				{/* Player list and start / join */}
				<Container>
					<LobbyPlayers lobbyId={lobbyId} />
				</Container>
				<Container>
					<LobbyActions lobbyId={lobbyId} />
				</Container>
			</div>
			{/* <div> */}
			{/* 	<LobbyRedirecter lobbyId={lobbyId} /> */}
			{/* 	<JoinLobbyButton lobbyId={lobbyId} /> */}
			{/* 	<br /> */}
			{/* 	<StartGameButton lobbyId={lobbyId} /> */}
			{/* 	<LobbyPlayers lobbyId={lobbyId} /> */}
			{/* 	<LeaveLobbyButton lobbyId={lobbyId} /> */}
			{/* </div> */}
		</div>
	);
}
