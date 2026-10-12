set search_path to public;

/*
 ==========================================

 (BR-13) Un client ne peut pas avoir deux réservations en attente, confirmées ou terminées pour une même date et un même service.

 Reservations:
 INSERT: Oui car il pourrait déjà y avoir une réservation
 UPDATE: Oui, idem que insert
 DELETE: non

 Services:
 INSERT: non
 UPDATE: Oui si l'heure de début ou de fin change
 DELETE: non

 ==========================================
*/
create or replace function check_no_double_resa() returns trigger as
$$
    begin
        if exists(select r.client, r.datetime::date, s.id from reservations r
                join services s on s.restaurant = r.restaurant and s.day_of_week = extract(ISODOW from r.datetime)
                where r.datetime::time >= s.start_time and r.datetime::time <= s.end_time
                and r.status in ('pending'::status_type, 'confirmed'::status_type, 'completed'::status_type)
                group by r.client, r.datetime::date, s.id having count(*) >=2) then
            raise exception 'A customer cannot have two pending, confirmed or completed reservations for the same service';
        end if;
        return null;
    end;
$$ language plpgsql;

create or replace trigger check_no_doubles_on_resa
    after insert or update
    on reservations
    for each row
execute procedure check_no_double_resa();

create or replace trigger check_no_doubles_on_services
    after update
    on services
    for each row
execute procedure check_no_double_resa();
