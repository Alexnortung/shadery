"use client";

import { useLeaveLobby } from "@/lib/lobby/leave";
import { LobbyId } from "@/lib/type-aliases";

type Props = {
	lobbyId: LobbyId;
};

const LeaveLobbyButton = ({ lobbyId }: Props) => {
	const { mutateAsync: leaveLobby, isPending } = useLeaveLobby();

	return (
		<button
			type="button"
			onClick={() => {
				leaveLobby({ lobbyId });
			}}
			disabled={isPending}
		>
			Leave
		</button>
	);
};

export default LeaveLobbyButton;
