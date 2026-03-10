create view "auth_joined_lobby" with (security_invoker = true) as
select distinct l.id as lobby_id, al.auth_uid as auth_uid from lobbies l
inner join lobby_players lp
    on l.id = lp.lobby_id
inner join auth_lobby al
    on lp.id = al.player_id

