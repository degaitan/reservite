set search_path to public;

/*
 ==========================================

 (BR-03) Les tables associées à une réservation doivent appartenir au restaurant de la réservation.

 ==========================================
 */


create or replace function check_same_restaurant() returns trigger as
$$
    begin
        if (select reservations.restaurant from reservations where reservations.id = new.reservation) is distinct from
           (select tables.restaurant from tables where tables.id = new."table") then
            raise exception 'Table must be in the same restaurant as reservation';
        end if;
        return new;
    end;
$$ language plpgsql;

create or replace trigger check_table_belongs_to_rest
before insert or update
    on reservation_tables
    for each row
execute procedure check_same_restaurant();
