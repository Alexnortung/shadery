"use client";

import { Button } from "@/components/ui/button";
import { useLeaveLobby } from "@/lib/lobby/leave";
import { LobbyId } from "@/lib/type-aliases";

type Props = {
	lobbyId: LobbyId;
};

const LeaveLobbyButton = ({ lobbyId }: Props) => {
	const { mutateAsync: leaveLobby, isPending } = useLeaveLobby();

	return (
		<Button
			variant="secondary"
			onClick={() => {
				leaveLobby({ lobbyId });
			}}
			disabled={isPending}
		>
			Leave
		</Button>
	);
};

export default LeaveLobbyButton;
