create or replace view game_player_with_score with (security_invoker = true) as
select
    p.id,
    p.game_id,
    p.player_number,
    (select count(*) from game_get_players_current_fields_ids(p.id)) as score
from game_players p
;
