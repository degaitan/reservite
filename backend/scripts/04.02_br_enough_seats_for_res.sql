set search_path to public;

/*
 ==========================================

 (BR-02) Le nombre de convives d'une réservation confirmée ou terminée ne peut pas dépasser la capacité totale
 des tables associées à la réservation.
 Ceci implique qu'une réservation confirmée ou terminée doit avoir au moins une table réservée
 appartenant au restaurant de la réservation.


 Reservations:
 INSERT: oui si la réservation insérée est confimée ou terminée
 UPDATE: oui si on change le statut de la réservation ou le nombre d'invités
 DELETE: non

 Reservation_tables:
 INSERT: non
 UPDATE: non car update interdit sur cette table
 DELETE: oui si on supprime une table d'une resa confirmed ou completed

 Tables:
 INSERT: non
 UPDATE: oui si on change la capacité d'une table rattachée à une réservation existante
 DELETE: oui si on supprime une table rattachée à une réservation existante

 ==========================================
 */

create or replace function check_enough_table_capacity_for_guests() returns trigger as
$$
    begin
        if exists(select r.id, r.number_of_guests, coalesce(sum(t.capacity), 0) from reservations r
                                left join reservation_tables rt on r.id = rt.reservation
                                left join tables t on rt."table" = t.id
                    where r.status in ('confirmed'::status_type, 'completed'::status_type)
                    group by r.id, r.number_of_guests having r.number_of_guests > coalesce(sum(t.capacity), 0)) then
            raise exception 'Number of guests must be less than or equal to total capacity';
        end if;
        return null;
    end;
$$ language plpgsql security definer ;


create or replace trigger check_capacity_resa
    after insert or update of number_of_guests, status
    on reservations
    for each row
execute procedure check_enough_table_capacity_for_guests();

create constraint trigger check_still_enough_capacity
    after delete
    on reservation_tables
    deferrable initially deferred
    for each row
execute procedure check_enough_table_capacity_for_guests();

create or replace trigger check_still_enough_capa_on_table
    after update or delete
    on tables
    for each row
execute procedure check_enough_table_capacity_for_guests();
