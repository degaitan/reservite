set search_path to public;

/*
    (BR-04) L'heure d'une réservation confirmée, terminée ou en attente doit être comprise entre l'heure de début et
    l'heure de fin d'un service pour le même jour de la semaine.
 */


/*
  New.status peut représenter des colonnes différentes en fonction de la table sur laquelle est déclenchée le trigger
  On fait un requête plus globale pour vérifier si les données sont toujours correctes, en AFTER
  Plus besoin de new/old
 */

create or replace function reservation_time() returns trigger as
    $$
        begin
            if exists(select 1
                      from reservations resa
                      where resa.status in ('confirmed'::status_type, 'pending'::status_type, 'completed'::status_type)
                      and not exists(select 1
                                     from services s
                                     where s.restaurant = resa.restaurant and
                                    extract(isodow from resa.datetime) = s.day_of_week and
                                    (resa.datetime::time >= s.start_time and resa.datetime::time <= s.end_time)
                                     )) then
                raise exception 'Reservation time outside of service window';
            end if;
            return null;
        end;
    $$language plpgsql;


create or replace trigger check_reservation_time_resa
    after insert or update of status, datetime
    on reservations
    for each row
    execute procedure reservation_time();

create or replace trigger check_reservation_time_service
    after delete or update
    on services
    for each row
    execute procedure reservation_time();

/*insert into reservations (client, restaurant, datetime, number_of_guests, status)
values (3, 1, '2025-11-03 16:00', 2, 'pending');

delete from services where id = 10;*/