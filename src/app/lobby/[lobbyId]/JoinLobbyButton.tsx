"use client";

import { useJoinLobby } from "@/lib/lobby/join";
import { LobbyId } from "@/lib/type-aliases";

type Props = {
	lobbyId: LobbyId;
};

const JoinLobbyButton = ({ lobbyId }: Props) => {
	const { mutateAsync: joinLobby, isPending } = useJoinLobby();

	return (
		<button
			type="button"
			onClick={() => {
				joinLobby({ lobbyId });
			}}
			disabled={isPending}
		>
			Join lobby
		</button>
	);
};

export default JoinLobbyButton;
