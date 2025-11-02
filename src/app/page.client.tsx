"use client";

import { Button } from "@/components/ui/button";
import { useIsAuthenticating, useSignInAsGuest } from "@/lib/auth/authenticate";
import { useIsLoggedIn } from "@/lib/auth/user";
import { useCreateLobby } from "@/lib/lobby/create";
import Link from "next/link";
import { useRouter } from "next/navigation";

const HomeClient = () => {
	const { data: isLoggedIn, isPending } = useIsLoggedIn();
	const isAuthenticating = useIsAuthenticating();
	const { mutateAsync: signInAsGuest } = useSignInAsGuest();
	const { mutateAsync: createLobby, isPending: isCreatingLobby } =
		useCreateLobby();
	const router = useRouter();
	// const { } = useLobb
	if (isPending) {
		return <div>Loading...</div>;
	}
	if (!isLoggedIn) {
		return (
			<div className="grid grid-cols-2 gap-6">
				<Button size="lg" asChild disabled={isAuthenticating}>
					<Link href="/sign-in">Login / Sign up</Link>
				</Button>
				<Button
					size="lg"
					disabled={isAuthenticating}
					onClick={() => signInAsGuest()}
				>
					Continue as guest
				</Button>
			</div>
		);
	}
	return (
		<div>
			<Button
				size="lg"
				onClick={async () => {
					const lobbyId = await createLobby();
					router.push(`/lobby/${lobbyId}`);
				}}
				disabled={isCreatingLobby}
			>
				Create game
			</Button>
			{/* <Button size="lg" asChild> */}
			{/* 	<Link href="/lobby/join">Join game</Link> */}
			{/* </Button> */}
		</div>
	);
};

export default HomeClient;
