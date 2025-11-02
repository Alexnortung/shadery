import type { Meta, StoryObj } from "@storybook/nextjs";
import { fn } from "storybook/test";
import { Button } from "./button";

const meta = {
	title: "Atoms/Button",
	component: Button,
	parameters: {
		layout: "centered",
	},
	tags: ["autodocs"],
	args: {
		onClick: fn(),
		children: "Button",
	},
} satisfies Meta<typeof Button>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
	args: {},
};
