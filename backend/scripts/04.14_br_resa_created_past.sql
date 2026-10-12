set search_path to public;

/*
 ==========================================

(BR-14) Une réservation ne peut pas être créée dans le passé (ne doit être vérifié qu'au moment de la création).
    remarque : on prend en compte le temps simulé si défini, sinon on prend le temps réel
 ==========================================
 */

/*
 coalesce prend deux param et retourne le premier qui est non null (plus court qu'un double exist)
 */

create or replace function resa_created_past() returns trigger as
    $$
    begin
        if new.datetime < coalesce(
                          (select system_time.simulated_time from system_time),
                          now()
                          ) then
            raise exception 'Cannot create a reservation in the past';
        end if;
        return new;
    end;
    $$language plpgsql;

create or replace trigger check_resa_created_past
    before insert on reservations
    for each row
    execute function resa_created_past();


/*insert into reservations (client, restaurant, datetime, number_of_guests, status)
values (3, 3, '2024-11-01 19:00', 2, 'pending');

insert into reservations (client, restaurant, datetime, number_of_guests, status)
values (3, 3, '2025-06-04 19:00', 2, 'pending');
*/