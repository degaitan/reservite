set search_path to public;

/*
 ==========================================

 (BR-01) Une réservation doit être associée à un utilisateur ayant le rôle de client.

 ==========================================
 */

 create or replace function check_client_for_res()
 returns trigger as
$$
     begin
         if new.client not in (select users.id from users where users.role = 'client') then
             raise exception 'A reservation must be associated with a client user';
         end if;
         return new;
     end;
$$ language plpgsql;

 create or replace trigger check_client_reservation
    before insert or update
    on reservations
    for each row
execute procedure check_client_for_res();