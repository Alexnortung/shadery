create sequence "public"."game_fields_id_seq";

create sequence "public"."game_players_id_seq";

create sequence "public"."games_id_seq";

create sequence "public"."lobby_players_id_seq";

create table "public"."auth_game" (
    "auth_uid" uuid not null,
    "player_id" bigint not null
);


alter table "public"."auth_game" enable row level security;

create table "public"."auth_lobby" (
    "auth_uid" uuid not null,
    "player_id" bigint not null
);


alter table "public"."auth_lobby" enable row level security;

create table "public"."game_fields" (
    "id" bigint not null default nextval('game_fields_id_seq'::regclass),
    "game_id" bigint,
    "field_value" integer,
    "x" integer not null,
    "y" integer not null
);


alter table "public"."game_fields" enable row level security;

create table "public"."game_players" (
    "id" bigint not null default nextval('game_players_id_seq'::regclass),
    "game_id" bigint,
    "position_x" integer not null,
    "position_y" integer not null,
    "player_number" integer not null
);


alter table "public"."game_players" enable row level security;

create table "public"."games" (
    "id" bigint not null default nextval('games_id_seq'::regclass),
    "size_x" integer not null,
    "size_y" integer not null,
    "current_player_number" integer not null,
    "ended_at" timestamp with time zone,
    "created_at" timestamp with time zone not null default now()
);


alter table "public"."games" enable row level security;

create table "public"."lobbies" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "ended_at" timestamp with time zone
);


alter table "public"."lobbies" enable row level security;

create table "public"."lobby_players" (
    "id" bigint not null default nextval('lobby_players_id_seq'::regclass),
    "lobby_id" uuid,
    "player_number" integer not null
);


alter table "public"."lobby_players" enable row level security;

alter sequence "public"."game_fields_id_seq" owned by "public"."game_fields"."id";

alter sequence "public"."game_players_id_seq" owned by "public"."game_players"."id";

alter sequence "public"."games_id_seq" owned by "public"."games"."id";

alter sequence "public"."lobby_players_id_seq" owned by "public"."lobby_players"."id";

CREATE UNIQUE INDEX auth_game_player_id_key ON public.auth_game USING btree (player_id);

CREATE UNIQUE INDEX auth_lobby_player_id_key ON public.auth_lobby USING btree (player_id);

CREATE UNIQUE INDEX game_fields_pkey ON public.game_fields USING btree (id);

CREATE UNIQUE INDEX game_players_pkey ON public.game_players USING btree (id);

CREATE UNIQUE INDEX games_pkey ON public.games USING btree (id);

CREATE UNIQUE INDEX lobbies_pkey ON public.lobbies USING btree (id);

CREATE UNIQUE INDEX lobby_players_pkey ON public.lobby_players USING btree (id);

CREATE UNIQUE INDEX uq_field_position ON public.game_fields USING btree (game_id, x, y);

CREATE UNIQUE INDEX uq_lobby_players_number ON public.lobby_players USING btree (lobby_id, player_number);

CREATE UNIQUE INDEX uq_player_number ON public.game_players USING btree (game_id, player_number);

CREATE UNIQUE INDEX uq_player_position ON public.game_players USING btree (game_id, position_x, position_y);

alter table "public"."game_fields" add constraint "game_fields_pkey" PRIMARY KEY using index "game_fields_pkey";

alter table "public"."game_players" add constraint "game_players_pkey" PRIMARY KEY using index "game_players_pkey";

alter table "public"."games" add constraint "games_pkey" PRIMARY KEY using index "games_pkey";

alter table "public"."lobbies" add constraint "lobbies_pkey" PRIMARY KEY using index "lobbies_pkey";

alter table "public"."lobby_players" add constraint "lobby_players_pkey" PRIMARY KEY using index "lobby_players_pkey";

alter table "public"."auth_game" add constraint "auth_game_player_id_fkey" FOREIGN KEY (player_id) REFERENCES game_players(id) ON DELETE CASCADE not valid;

alter table "public"."auth_game" validate constraint "auth_game_player_id_fkey";

alter table "public"."auth_game" add constraint "auth_game_player_id_key" UNIQUE using index "auth_game_player_id_key";

alter table "public"."auth_lobby" add constraint "auth_lobby_player_id_fkey" FOREIGN KEY (player_id) REFERENCES lobby_players(id) ON DELETE CASCADE not valid;

alter table "public"."auth_lobby" validate constraint "auth_lobby_player_id_fkey";

alter table "public"."auth_lobby" add constraint "auth_lobby_player_id_key" UNIQUE using index "auth_lobby_player_id_key";

alter table "public"."game_fields" add constraint "game_fields_game_id_fkey" FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE not valid;

alter table "public"."game_fields" validate constraint "game_fields_game_id_fkey";

alter table "public"."game_fields" add constraint "uq_field_position" UNIQUE using index "uq_field_position";

alter table "public"."game_players" add constraint "game_players_game_id_fkey" FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE not valid;

alter table "public"."game_players" validate constraint "game_players_game_id_fkey";

alter table "public"."game_players" add constraint "uq_player_number" UNIQUE using index "uq_player_number";

alter table "public"."game_players" add constraint "uq_player_position" UNIQUE using index "uq_player_position";

alter table "public"."lobby_players" add constraint "lobby_players_lobby_id_fkey" FOREIGN KEY (lobby_id) REFERENCES lobbies(id) ON DELETE CASCADE not valid;

alter table "public"."lobby_players" validate constraint "lobby_players_lobby_id_fkey";

alter table "public"."lobby_players" add constraint "uq_lobby_players_number" UNIQUE using index "uq_lobby_players_number";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.game_get_player(the_game_id bigint)
 RETURNS game_players
 LANGUAGE plpgsql
AS $function$
begin
    return (
        select *
        from game_players p
        inner join auth_game ag
            on p.player_id = ag.player_id
        where p.game_id = the_game_id
        and ag.auth_uid = auth.uid()
    );
end;
$function$
;

CREATE OR REPLACE FUNCTION public.game_get_players_current_fields_ids(player_id bigint)
 RETURNS SETOF bigint
 LANGUAGE plpgsql
AS $function$
DECLARE
    the_game_id BIGINT;
    initial_pos_x INT;
    initial_pos_y INT;
BEGIN
    -- Get initial player position
    SELECT p.game_id, p.position_x, p.position_y
    INTO the_game_id, initial_pos_x, initial_pos_y
    FROM game_players p
    WHERE p.id = player_id;

    -- Recursive search for connected fields with same value
    RETURN QUERY
    WITH RECURSIVE fields AS (
        SELECT f.id, f.x, f.y, f.field_value
        FROM game_fields f
        WHERE f.game_id = the_game_id AND f.x = initial_pos_x AND f.y = initial_pos_y

        UNION

        SELECT f2.id, f2.x, f2.y, f2.field_value
        FROM game_fields f2
        INNER JOIN fields f1 ON f2.game_id = the_game_id AND f2.field_value = f1.field_value AND (
            (f2.x = f1.x + 1 AND f2.y = f1.y) OR
            (f2.x = f1.x - 1 AND f2.y = f1.y) OR
            (f2.x = f1.x AND f2.y = f1.y + 1) OR
            (f2.x = f1.x AND f2.y = f1.y - 1)
        )
    )
    SELECT id FROM fields;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.game_play_logic(the_game_id bigint, player_number integer, value integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
    player_id bigint;
begin
    -- update the game fields based on the player's fields
    select p.id into player_id
    from game_players p
    where p.game_id = the_game_id
    and p.player_number = game_play_logic.player_number;

    update game_fields f
    set field_value = value
    where f.id in (
        select * from game_get_players_current_fields_ids(player_id)
    );
    
    -- for now, just upate the current player turn
    perform game_set_next_player(the_game_id, player_number);

    -- TODO: check if a player has won
end;
$function$
;

CREATE OR REPLACE FUNCTION public.game_player_play(the_game_id bigint, value integer)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
    player game_players%rowtype;
    game games%rowtype;
begin
    -- Get the game
    select g.* into game
    from games g
    where g.id = the_game_id;

    if not found then
        raise exception 'Game not found';
    end if;

    -- Get the player
    select * into player
    from game_get_player(the_game_id);
    
    if not found then
        raise exception 'Player not found';
    end if;

    -- check if the game is active
    if game.ended_at is not null then
        raise exception 'Game has ended';
    end if;

    -- check if it is currently the player's turn
    if game.current_player != player.player_number then
        raise exception 'It is not your turn';
    end if;

    -- TODO: check if the value is valid

    -- Run play logic
end;
$function$
;

CREATE OR REPLACE FUNCTION public.game_set_next_player(the_game_id bigint, player_number integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare
    next_player int;
begin
    -- get the next player
    select p.player_number into next_player
    from game_players p
    where p.game_id = the_game_id
    and p.player_number > game_set_next_player.player_number
    order by p.player_number asc
    limit 1;

    if next_player is null then
        -- get the first player instead
        select p.player_number into next_player
        from game_players p
        where p.game_id = the_game_id
        order by p.player_number asc
        limit 1;
    end if;

    -- update the current player number in the game table
    update games g
    set current_player_number = next_player
    where g.id = the_game_id;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.lobby_player_join(the_lobby_id bigint)
 RETURNS bigint
 LANGUAGE plpgsql
AS $function$
declare
    player lobby_players%rowtype;
    lobby lobbies%rowtype;
    next_player_number int;
begin
    -- Get the lobby
    select l.* into lobby
    from lobbies l
    where l.id = the_lobby_id;

    if not found then
        raise exception 'Lobby not found';
    end if;

    -- Check if the lobby is active
    if lobby.ended_at is not null then
        raise exception 'Lobby has ended';
    end if;

    -- Get the next player number
    select coalesce(max(lp.player_number) + 1, 0) into next_player_number
    from lobby_players lp
    where lp.lobby_id = the_lobby_id;

    -- Create the player
    insert into lobby_players (lobby_id, player_number)
    values (the_lobby_id, next_player_number)
    returning * into player;

    return player.id;
end;
$function$
;

grant delete on table "public"."auth_game" to "anon";

grant insert on table "public"."auth_game" to "anon";

grant references on table "public"."auth_game" to "anon";

grant select on table "public"."auth_game" to "anon";

grant trigger on table "public"."auth_game" to "anon";

grant truncate on table "public"."auth_game" to "anon";

grant update on table "public"."auth_game" to "anon";

grant delete on table "public"."auth_game" to "authenticated";

grant insert on table "public"."auth_game" to "authenticated";

grant references on table "public"."auth_game" to "authenticated";

grant select on table "public"."auth_game" to "authenticated";

grant trigger on table "public"."auth_game" to "authenticated";

grant truncate on table "public"."auth_game" to "authenticated";

grant update on table "public"."auth_game" to "authenticated";

grant delete on table "public"."auth_game" to "service_role";

grant insert on table "public"."auth_game" to "service_role";

grant references on table "public"."auth_game" to "service_role";

grant select on table "public"."auth_game" to "service_role";

grant trigger on table "public"."auth_game" to "service_role";

grant truncate on table "public"."auth_game" to "service_role";

grant update on table "public"."auth_game" to "service_role";

grant delete on table "public"."auth_lobby" to "anon";

grant insert on table "public"."auth_lobby" to "anon";

grant references on table "public"."auth_lobby" to "anon";

grant select on table "public"."auth_lobby" to "anon";

grant trigger on table "public"."auth_lobby" to "anon";

grant truncate on table "public"."auth_lobby" to "anon";

grant update on table "public"."auth_lobby" to "anon";

grant delete on table "public"."auth_lobby" to "authenticated";

grant insert on table "public"."auth_lobby" to "authenticated";

grant references on table "public"."auth_lobby" to "authenticated";

grant select on table "public"."auth_lobby" to "authenticated";

grant trigger on table "public"."auth_lobby" to "authenticated";

grant truncate on table "public"."auth_lobby" to "authenticated";

grant update on table "public"."auth_lobby" to "authenticated";

grant delete on table "public"."auth_lobby" to "service_role";

grant insert on table "public"."auth_lobby" to "service_role";

grant references on table "public"."auth_lobby" to "service_role";

grant select on table "public"."auth_lobby" to "service_role";

grant trigger on table "public"."auth_lobby" to "service_role";

grant truncate on table "public"."auth_lobby" to "service_role";

grant update on table "public"."auth_lobby" to "service_role";

grant delete on table "public"."game_fields" to "anon";

grant insert on table "public"."game_fields" to "anon";

grant references on table "public"."game_fields" to "anon";

grant select on table "public"."game_fields" to "anon";

grant trigger on table "public"."game_fields" to "anon";

grant truncate on table "public"."game_fields" to "anon";

grant update on table "public"."game_fields" to "anon";

grant delete on table "public"."game_fields" to "authenticated";

grant insert on table "public"."game_fields" to "authenticated";

grant references on table "public"."game_fields" to "authenticated";

grant select on table "public"."game_fields" to "authenticated";

grant trigger on table "public"."game_fields" to "authenticated";

grant truncate on table "public"."game_fields" to "authenticated";

grant update on table "public"."game_fields" to "authenticated";

grant delete on table "public"."game_fields" to "service_role";

grant insert on table "public"."game_fields" to "service_role";

grant references on table "public"."game_fields" to "service_role";

grant select on table "public"."game_fields" to "service_role";

grant trigger on table "public"."game_fields" to "service_role";

grant truncate on table "public"."game_fields" to "service_role";

grant update on table "public"."game_fields" to "service_role";

grant delete on table "public"."game_players" to "anon";

grant insert on table "public"."game_players" to "anon";

grant references on table "public"."game_players" to "anon";

grant select on table "public"."game_players" to "anon";

grant trigger on table "public"."game_players" to "anon";

grant truncate on table "public"."game_players" to "anon";

grant update on table "public"."game_players" to "anon";

grant delete on table "public"."game_players" to "authenticated";

grant insert on table "public"."game_players" to "authenticated";

grant references on table "public"."game_players" to "authenticated";

grant select on table "public"."game_players" to "authenticated";

grant trigger on table "public"."game_players" to "authenticated";

grant truncate on table "public"."game_players" to "authenticated";

grant update on table "public"."game_players" to "authenticated";

grant delete on table "public"."game_players" to "service_role";

grant insert on table "public"."game_players" to "service_role";

grant references on table "public"."game_players" to "service_role";

grant select on table "public"."game_players" to "service_role";

grant trigger on table "public"."game_players" to "service_role";

grant truncate on table "public"."game_players" to "service_role";

grant update on table "public"."game_players" to "service_role";

grant delete on table "public"."games" to "anon";

grant insert on table "public"."games" to "anon";

grant references on table "public"."games" to "anon";

grant select on table "public"."games" to "anon";

grant trigger on table "public"."games" to "anon";

grant truncate on table "public"."games" to "anon";

grant update on table "public"."games" to "anon";

grant delete on table "public"."games" to "authenticated";

grant insert on table "public"."games" to "authenticated";

grant references on table "public"."games" to "authenticated";

grant select on table "public"."games" to "authenticated";

grant trigger on table "public"."games" to "authenticated";

grant truncate on table "public"."games" to "authenticated";

grant update on table "public"."games" to "authenticated";

grant delete on table "public"."games" to "service_role";

grant insert on table "public"."games" to "service_role";

grant references on table "public"."games" to "service_role";

grant select on table "public"."games" to "service_role";

grant trigger on table "public"."games" to "service_role";

grant truncate on table "public"."games" to "service_role";

grant update on table "public"."games" to "service_role";

grant delete on table "public"."lobbies" to "anon";

grant insert on table "public"."lobbies" to "anon";

grant references on table "public"."lobbies" to "anon";

grant select on table "public"."lobbies" to "anon";

grant trigger on table "public"."lobbies" to "anon";

grant truncate on table "public"."lobbies" to "anon";

grant update on table "public"."lobbies" to "anon";

grant delete on table "public"."lobbies" to "authenticated";

grant insert on table "public"."lobbies" to "authenticated";

grant references on table "public"."lobbies" to "authenticated";

grant select on table "public"."lobbies" to "authenticated";

grant trigger on table "public"."lobbies" to "authenticated";

grant truncate on table "public"."lobbies" to "authenticated";

grant update on table "public"."lobbies" to "authenticated";

grant delete on table "public"."lobbies" to "service_role";

grant insert on table "public"."lobbies" to "service_role";

grant references on table "public"."lobbies" to "service_role";

grant select on table "public"."lobbies" to "service_role";

grant trigger on table "public"."lobbies" to "service_role";

grant truncate on table "public"."lobbies" to "service_role";

grant update on table "public"."lobbies" to "service_role";

grant delete on table "public"."lobby_players" to "anon";

grant insert on table "public"."lobby_players" to "anon";

grant references on table "public"."lobby_players" to "anon";

grant select on table "public"."lobby_players" to "anon";

grant trigger on table "public"."lobby_players" to "anon";

grant truncate on table "public"."lobby_players" to "anon";

grant update on table "public"."lobby_players" to "anon";

grant delete on table "public"."lobby_players" to "authenticated";

grant insert on table "public"."lobby_players" to "authenticated";

grant references on table "public"."lobby_players" to "authenticated";

grant select on table "public"."lobby_players" to "authenticated";

grant trigger on table "public"."lobby_players" to "authenticated";

grant truncate on table "public"."lobby_players" to "authenticated";

grant update on table "public"."lobby_players" to "authenticated";

grant delete on table "public"."lobby_players" to "service_role";

grant insert on table "public"."lobby_players" to "service_role";

grant references on table "public"."lobby_players" to "service_role";

grant select on table "public"."lobby_players" to "service_role";

grant trigger on table "public"."lobby_players" to "service_role";

grant truncate on table "public"."lobby_players" to "service_role";

grant update on table "public"."lobby_players" to "service_role";

create policy "Allow users to create lobbies"
on "public"."lobbies"
as permissive
for insert
to public
with check (true);


create policy "Allow users to see their lobbies"
on "public"."lobbies"
as permissive
for select
to public
using ((EXISTS ( SELECT 1
   FROM (auth_lobby al
     JOIN lobby_players p ON ((al.player_id = p.id)))
  WHERE ((al.auth_uid = auth.uid()) AND (p.lobby_id = lobbies.id)))));


create policy "Allow users to see players in their lobbies"
on "public"."lobby_players"
as permissive
for select
to public
using ((EXISTS ( SELECT 1
   FROM (auth_lobby al
     JOIN lobby_players p ON ((al.player_id = p.id)))
  WHERE ((al.auth_uid = auth.uid()) AND (p.lobby_id = lobby_players.lobby_id)))));



