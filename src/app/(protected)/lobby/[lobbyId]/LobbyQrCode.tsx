"use client";

import { PUBLIC_URL } from "@/lib/constants";
import { LobbyId } from "@/lib/type-aliases";
import QRCode from "react-qr-code";

type Props = {
	lobbyId: LobbyId;
};

const LobbyQrCode = ({ lobbyId }: Props) => {
	const url = `${PUBLIC_URL}/lobby/${lobbyId}`;

	return <QRCode value={url} size={256} className="mx-auto" />;
};

export default LobbyQrCode;
