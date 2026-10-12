set search_path to public;

/*
 ==========================================

 (BR-12) Une réservation en attente ou annulée ne peut être associée à aucune une table.


 Reservation_tables:
 INSERT: Oui, on ne peut pas insérer de table pour une mauvaise résa
 UPDATE: Idem que insert
 DELETE: pas de problème

 Reservation:
 INSERT: pas de problème
 UPDATE: Si on change le statut d'une réservation, il faut vérifier qu'aucune table ne lui est associée
 DELETE: pas de problème

 ==========================================
 */

create or replace function check_status_for_new_tables() returns trigger as
$$
    begin
        if new.reservation in (select rt.reservation from reservation_tables rt
                                                     join reservations r on r.id = rt.reservation
                        where r.status in ('pending'::status_type, 'cancelled'::status_type)) then
            raise exception 'A table cannot be associated with a pending or cancelled reservation';
        end if;
        return new;
    end;
$$ language plpgsql security definer ;

create or replace function check_no_tables() returns trigger as
$$
    begin
        if new.status in ('pending'::status_type, 'cancelled'::status_type) and new.id in (select rt.reservation from reservation_tables rt) then
            raise exception 'A table cannot be associated with a pending or cancelled reservation';
        end if;
        return new;
    end;
$$ language plpgsql security definer ;

create constraint trigger check_not_pending_or_cancelled
after insert or update
    on reservation_tables
    deferrable initially deferred
    for each row
    execute procedure check_status_for_new_tables();

create or replace trigger check_nothing_for_pending_or_cancelled
before update on reservations
    for each row
    execute procedure check_no_tables();
