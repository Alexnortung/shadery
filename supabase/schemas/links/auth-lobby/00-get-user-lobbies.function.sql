CREATE OR REPLACE FUNCTION get_user_lobby_ids()
RETURNS SETOF uuid -- Or integer, whatever your lobby_id type is
LANGUAGE plpgsql
SECURITY DEFINER -- Essential: This function will run with definer's rights, bypassing RLS on underlying tables for THIS function's query only.
AS $$
BEGIN
  RETURN QUERY
  SELECT lp.lobby_id
  FROM lobby_players lp
    JOIN auth_lobby al ON al.player_id = lp.id
    WHERE al.auth_uid = auth.uid();
END;
$$;
