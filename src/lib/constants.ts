export const PUBLIC_URL =
	process.env.NEXT_PUBLIC_URL ||
	(process.env.VERCEL_URL
		? `https://${process.env.VERCEL_URL}`
		: process.env.NODE_ENV === "development"
			? "http://localhost:3000"
			: "");
