set search_path to public;

/*
 ==========================================

 (BR-07) Pour un même jour de la semaine, les services d'un restaurant ne peuvent pas se chevaucher.

 Services:

 INSERT: oui car un nouveau service peut en chevaucher un autre
 UPDATE: oui, idem que pour insert
 DELETE: non

 ==========================================
 */

create or replace function check_no_overlapping_services()
returns trigger as
$$
    begin
        if exists(select 1 from services s where s.id is distinct from new.id
                                            and s.day_of_week = new.day_of_week
                                            and s.restaurant = new.restaurant
                                            and (s.start_time, s.end_time) overlaps (new.start_time, new.end_time)) then
            raise exception 'Services may not overlap on the same day_of_week';
        end if;
        return new;
    end;
$$ language plpgsql;

create or replace trigger no_overlaps
    before insert or update
    on services
    for each row
execute procedure check_no_overlapping_services();

