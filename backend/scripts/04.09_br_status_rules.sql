set search_path to public;

/*
    (BR-09) Une nouvelle réservation doit avoir le status pending. Une réservation existante ne peut pas revenir "en arrière"
    dans son cycle de vie. Les transitions autorisées sont :
        pending -> confirmed
        pending -> cancelled
        confirmed -> completed
        confirmed -> cancelled
 */

 create or replace function status_rules() returns trigger as
     $$
     begin
         if(tg_op = 'UPDATE' and new.status = old.status) then
             return new;
         end if;
         if(tg_op = 'INSERT' and new.status is distinct from 'pending'::status_type) then
             raise exception 'Status must be pending for a new reservation';
         else if(tg_op = 'UPDATE' and ((old.status = 'pending' and new.status not in ('confirmed'::status_type, 'cancelled'::status_type))
                     or (old.status = 'confirmed'::status_type and new.status not in ('completed'::status_type, 'cancelled'::status_type, 'pending'::status_type)))) then
             raise exception 'Status of the reservation cannot go backwards';
         else if(tg_op = 'UPDATE' and  old.status in ('completed'::status_type, 'cancelled'::status_type)) then
             raise exception 'Cannot modify a completed or cancelled reservation';
         else if(tg_op = 'UPDATE' and new.status = 'pending' and old.status = 'confirmed' and new.datetime < coalesce((select system_time.simulated_time from system_time), now())) then
             raise exception 'Reservation must be in the future to change its status in this way';
         end if;
         end if;
         end if;
         end if;
         return new;

     end;
     $$language plpgsql;

create or replace trigger check_status_rules
    before insert or update of status on reservations
    for each row
    execute function status_rules();