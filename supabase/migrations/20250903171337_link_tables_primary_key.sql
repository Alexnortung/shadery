-- INDEX_BUILD: This might affect database performance. Concurrent index builds require a non-trivial amount of CPU, potentially affecting database performance. They also can take a while but do not lock out writes.
CREATE UNIQUE INDEX auth_game_pkey ON public.auth_game USING btree (auth_uid, player_id);

ALTER TABLE "public"."auth_game" ADD CONSTRAINT "auth_game_pkey" PRIMARY KEY USING INDEX "auth_game_pkey";

-- INDEX_BUILD: This might affect database performance. Concurrent index builds require a non-trivial amount of CPU, potentially affecting database performance. They also can take a while but do not lock out writes.
CREATE UNIQUE INDEX auth_lobby_pkey ON public.auth_lobby USING btree (auth_uid, player_id);

ALTER TABLE "public"."auth_lobby" ADD CONSTRAINT "auth_lobby_pkey" PRIMARY KEY USING INDEX "auth_lobby_pkey";

-- INDEX_BUILD: This might affect database performance. Concurrent index builds require a non-trivial amount of CPU, potentially affecting database performance. They also can take a while but do not lock out writes.
CREATE UNIQUE INDEX lobby_game_pkey ON public.lobby_game USING btree (lobby_id, game_id);

ALTER TABLE "public"."lobby_game" ADD CONSTRAINT "lobby_game_pkey" PRIMARY KEY USING INDEX "lobby_game_pkey";

