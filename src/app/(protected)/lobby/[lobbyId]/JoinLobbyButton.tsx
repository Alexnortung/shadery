"use client";

import { Button } from "@/components/ui/button";
import { useJoinLobby } from "@/lib/lobby/join";
import { LobbyId } from "@/lib/type-aliases";

type Props = {
	lobbyId: LobbyId;
};

const JoinLobbyButton = ({ lobbyId }: Props) => {
	const { mutateAsync: joinLobby, isPending } = useJoinLobby();

	return (
		<Button
			onClick={() => {
				joinLobby({ lobbyId });
			}}
			disabled={isPending}
		>
			Join lobby
		</Button>
	);
};

export default JoinLobbyButton;
