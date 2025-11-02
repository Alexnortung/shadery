import { Button } from "@/components/ui/button";
import HomeClient from "./page.client";

export default async function Home() {
	return (
		<main className="text-center flex flex-col justify-center">
			<h1 className="mb-6 text-6xl md:text-8xl">Shadery</h1>
			<div className="max-w-max mx-auto ">
				<HomeClient />
			</div>
		</main>
	);
}
