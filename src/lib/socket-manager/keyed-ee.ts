export class KeyedEventEmitter<
	Key extends string | Function = string | Function,
> {
	private map: Map<
		Key,
		{
			/** Count of listeners for this key */
			c: number;
			/** The listener function */
			f: (...args: any[]) => void;
		}
	> = new Map();

	on(key: Key, listener: (...args: any[]) => void): void {
		if (!this.map.has(key)) {
			this.map.set(key, { c: 0, f: listener });
		}
		const entry = this.map.get(key)!;
		entry.c += 1;
	}

	off(key: Key): boolean {
		const entry = this.map.get(key);
		if (!entry) {
			return true;
		}
		entry.c -= 1;
		if (entry.c <= 0) {
			this.map.delete(key);
			return true;
		}
		return false;
	}

	emitAll(...args: any[]): void {
		for (const entry of this.map.values()) {
			entry.f(...args);
		}
	}

	hasListeners(): boolean {
		return this.map.size > 0;
	}
}
