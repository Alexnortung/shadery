import { cn } from "@/lib/utils";
import { ComponentProps } from "react";

type Props = ComponentProps<"div">;

const Container = ({ className, ...rest }: Props) => {
	return <div className={cn("p-4 border rounded-md", className)} {...rest} />;
};

export default Container;
