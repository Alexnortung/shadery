CREATE OR REPLACE FUNCTION get_user_lobby_ids_by_user(the_auth_uid auth.users.id%type)
RETURNS SETOF public.lobbies.id%type
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT lp.lobby_id
  FROM lobby_players lp
    JOIN auth_lobby al ON al.player_id = lp.id
    WHERE al.auth_uid = the_auth_uid;
END;
$$;

CREATE OR REPLACE FUNCTION get_user_lobby_ids()
RETURNS SETOF public.lobbies.id%type
LANGUAGE plpgsql
SECURITY DEFINER -- Essential: This function will run with definer's rights, bypassing RLS on underlying tables for THIS function's query only.
AS $$
BEGIN
  RETURN QUERY
  SELECT get_user_lobby_ids_by_user(auth.uid());
END;
$$;
