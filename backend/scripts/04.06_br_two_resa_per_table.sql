set search_path to public;

/*
    (BR-06) Une table ne peut pas faire l'objet
    de deux réservations terminées ou confirmées pour une même date et un même service.
 */

/*
 Table reservation:
 INSERT:
 UPDATE: oui, si le status de la resa change
 DELETE:

 Table reservation_tables:
 INSERT: non, nouvelle resa donc statut "pending"
 UPDATE: oui, si la table change
 DELETE: non

 Table tables:
 */

create or replace function resa_per_table() returns trigger as
    $$
    begin
        if exists (select 1
                   from reservations resa1, reservations resa2
                   where resa1.status in ('completed'::status_type, 'confirmed'::status_type)
                     and resa2.status in('completed'::status_type, 'confirmed'::status_type)
                   and exists(select 1
                                  from services s,
                                       reservation_tables rt1,
                                       reservation_tables rt2
                                  where resa1.id = rt1.reservation and resa2.id = rt2.reservation
                                  and rt1."table" = rt2."table" and rt1.reservation <> rt2.reservation
                                  and resa1.restaurant = s.restaurant and resa2.restaurant = s.restaurant
                                    and resa1.datetime::date = resa2.datetime::date
                                    and extract(isodow from resa1.datetime)=s.day_of_week
                                    and (resa1.datetime::time >= s.start_time
                                      and resa2.datetime::time >= s.start_time
                                      and resa1.datetime::time <= s.end_time
                                      and resa2.datetime::time <= s.end_time))) then
            raise exception 'Two reservations cannot exist for the same table on the same date for the same service';

        end if;
        return null;
    end;
    $$language plpgsql;

create or replace trigger check_resa_per_table_res
    after insert or update on reservations
    for each row
    execute function resa_per_table();

create or replace trigger check_resa_per_table_rt
    after insert or update on reservation_tables
    for each row
    execute function resa_per_table();

/*
update reservation_tables set "table" = 1 where reservation = 4; c'est ok
update reservations set datetime = '2024-11-15 19:00:00' where id = 4; pas ok
*/