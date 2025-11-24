import { describe, expect, it, mock, spyOn } from "bun:test";
import { ConnectionTracker } from "./connection";

describe("ConnectionTracker", () => {
	describe("connect method", () => {
		it("should call the connectFn", async () => {
			const connectFn = mock(async ({ onEvent }) => {
				// Simulate successful connection
				return {
					disconnectFn: () => {
						// Disconnect function
					},
				};
			});
			const conn = new ConnectionTracker({
				connectFn,
			});
			await conn.connect();
			expect(connectFn).toHaveBeenCalledTimes(1);
		});

		it("should emit a connected event on successful connection", async () => {
			const conn = new ConnectionTracker({
				connectFn: async ({ onEvent }) => {
					// Simulate successful connection
					return {
						disconnectFn: () => {
							// Disconnect function
						},
					};
				},
			});
			const onConnected = mock(() => {});
			conn.on("connected", onConnected);

			await conn.connect();

			expect(onConnected).toHaveBeenCalledTimes(1);
		});
	});

	describe("disconnect method", () => {
		it("should call the disconnect function", async () => {
			const disconnectFn = mock(() => {});
			const conn = new ConnectionTracker({
				connectFn: async ({ onEvent }) => {
					// Simulate successful connection
					return {
						disconnectFn,
					};
				},
			});
			await conn.connect();
			conn.disconnect();
			expect(disconnectFn).toHaveBeenCalledTimes(1);
		});

		it("should emit a disconnected event on disconnection", async () => {
			const conn = new ConnectionTracker({
				connectFn: async ({ onEvent }) => {
					// Simulate successful connection
					return {
						disconnectFn: () => {
							// Disconnect function
						},
					};
				},
			});
			const onDisconnected = mock(() => {});
			conn.on("disconnected", onDisconnected);

			await conn.connect();
			await conn.disconnect();

			expect(onDisconnected).toHaveBeenCalledTimes(1);
		});
	});
});
