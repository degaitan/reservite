set search_path to public;

/*
    (BR-11) Une réservation terminée ou annulée ne peut pas être modifiée.
 */

 create or replace function update_completed_cancelled_resa() returns trigger as
     $$
     begin
         if(new is distinct from old and old.status in ('cancelled'::status_type, 'completed'::status_type)) then
             raise exception 'Cannot modify a cancelled or completed reservation';
         end if;
        return new;
     end;


     $$language plpgsql;

create or replace trigger check_update_completed_cancelled_resa
    before update on reservations
    for each row
    execute function update_completed_cancelled_resa();
