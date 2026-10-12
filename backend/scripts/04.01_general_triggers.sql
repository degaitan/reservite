set search_path to public;

/*
 ==========================================
 TABLE USERS
 ==========================================
 */

create or replace function check_user_role() returns trigger as
$$
     begin
         if new.role != old.role then
             raise exception 'Cannot change user role';
         end if;
         return new;
     end;
$$ language plpgsql;

create or replace trigger check_unchanged_user_role
    before update on users
    for each row
execute procedure check_user_role();

/*
 ==========================================
 TABLE TABLES
 ==========================================
 */

create or replace function update_restaurant_table()
returns trigger as
    $$
    begin
        if new.restaurant is distinct from old.restaurant then
            raise exception 'Cannot modify the restaurant';
        end if;
        return new;
    end;
    $$language plpgsql;

create trigger forbid_update_restaurant_table
    before update of restaurant on tables for each row
    execute function update_restaurant_table();

/*
 ==========================================
 TABLE SERVICES
 ==========================================
 */

 create or replace function restaurant_update() returns trigger as
$$
     begin
         if new.restaurant is distinct from old.restaurant then
             raise exception 'Cannot modify the restaurant for a service';
         end if;
         return new;
     end;
$$ language plpgsql;

create or replace trigger check_restaurant_update
    before update on services
    for each row
execute procedure restaurant_update();

/*
 ==========================================
 TABLE RESERVATIONS
 ==========================================
 */

 /*
  On ne peut pas modifier le resto ou client d'une resa
  */

create or replace function resa_update() returns trigger as
       $$
       begin
           if((new.restaurant is distinct from old.restaurant)
                  or new.client is distinct from old.client) then
               raise exception 'Cannot modify the restaurant or the cleint of an ongoing reservation';
           end if;
           return new;
       end;
       $$language plpgsql;

create or replace trigger check_resa_update
    before update on reservations
    for each row
    execute procedure resa_update();


/*
 En plus des transitions décrites ci-dessus, le statut d'une réservation peut passer de confirmed à pending
 uniquement si la réservation est dans le futur (pour permettre l'édition par le client).
 */

 create or replace function resa_confirmed_to_pending() returns trigger as
     $$
     begin
         if new.status = 'pending' and old.status = 'confirmed' then
             if new.datetime < coalesce((select system_time.simulated_time from system_time), now()) then
                 raise exception 'Reservation must be in the future to change its status in this way';
             end if;
         end if;
         return  new;
     end;
     $$language plpgsql;

create or replace trigger check_resa_confirmed_to_pending
    before update of status on reservations
    for each row
    execute procedure resa_confirmed_to_pending();

/*
 =======================================================
 PREVENT UPDATE RESERVATION_TABLES ET RESTAURANT_MANAGER
 =======================================================
 */

 create or replace function check_no_update()
 returns trigger as
$$
     begin
         if old is distinct from new then
             raise exception 'Primary keys cannot be updated';
         end if;
         return new;
     end;
$$ language plpgsql;

create or replace trigger no_update_rest_manager
before update on restaurant_managers
    for each row
execute procedure check_no_update();

create or replace trigger no_update_rest_manager
    before update on reservation_tables
    for each row
execute procedure check_no_update();
