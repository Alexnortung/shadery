import { createClient } from "@/utils/supabase/server";

type Props = {};

export default async function Page() {
	const supabase = await createClient();

	const {
		data: { user },
	} = await supabase.auth.getUser();

	return <div>Welcome to the lobby</div>;
}
