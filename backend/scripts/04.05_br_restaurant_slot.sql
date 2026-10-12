set search_path to public;

/*
 ==========================================

    (BR-05) Au moment de sa création ou de sa modification, l'heure d'une réservation doit correspondre à un créneau
 de réservation (slot) pour le restaurant. Un créneau de réservation doit toujours correspondre à une
 heure exacte (sans minutes) augmentée d'un multiple de la durée du créneau de réservation.

 ==========================================
 */

create or replace function slot_per_reservation() returns trigger as
    $$
        begin
            if exists (select *
                       from reservations resa, restaurants resto
                       where resa.restaurant = resto.id and extract(minute from resa.datetime)::int % resto.slot_duration <> 0) then
                raise exception 'Time of reservation outside of restaurant slot durations';
            end if;
            return null;
        end;
    $$language plpgsql;

create or replace trigger check_slot_per_reservation_resa
    after insert or update of datetime on reservations
    for each row
    execute function slot_per_reservation();

create or replace trigger check_slot_per_reservation_resto
    after update of slot_duration on restaurants
    for each row
execute function slot_per_reservation();

/*insert into reservations (client, restaurant, datetime, number_of_guests, status)
values (3, 1, '2025-11-04 13:17:00', 2, 'pending');

insert into reservations (client, restaurant, datetime, number_of_guests, status)
values (3, 1, '2025-11-04 13:30:00', 2, 'pending');*/
