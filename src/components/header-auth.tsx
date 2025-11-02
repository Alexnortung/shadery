"use client";

import { useUser } from "@/lib/auth/user";
import Loader from "./loader";
import {
	DropdownMenu,
	DropdownMenuContent,
	DropdownMenuItem,
	DropdownMenuPortal,
	DropdownMenuTrigger,
} from "./ui/dropdown-menu";
import { useIsAuthenticating, useSignOut } from "@/lib/auth/authenticate";
import { Button } from "./ui/button";
import Link from "next/link";

const HeaderAuth = () => {
	const { data: user, isLoading } = useUser();
	const { mutateAsync: signOut } = useSignOut();
	const isAuthenticating = useIsAuthenticating();

	if (isLoading) {
		return <Loader />;
	}
	if (!user) {
		return (
			<div className="flex gap-2">
				<Button size="sm" asChild>
					<Link href="/sign-in">Sign In</Link>
				</Button>
				<Button size="sm" asChild variant="secondary">
					<Link href="/sign-up">Sign Up</Link>
				</Button>
			</div>
		);
	}

	// return <div>{user.is_anonymous ? "Guest" : user.email}</div>;
	return (
		<DropdownMenu>
			<DropdownMenuTrigger>
				{user.is_anonymous ? "Guest" : user.email}
			</DropdownMenuTrigger>
			<DropdownMenuPortal>
				<DropdownMenuContent>
					<DropdownMenuItem>Profile</DropdownMenuItem>
					<DropdownMenuItem
						disabled={isAuthenticating}
						onClick={() => signOut()}
					>
						Sign out
					</DropdownMenuItem>
				</DropdownMenuContent>
			</DropdownMenuPortal>
		</DropdownMenu>
	);
};

export default HeaderAuth;
