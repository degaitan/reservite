set search_path to public;

/*
    (BR-10) Un restaurant doit avoir au moins un manager.
 */

 create or replace function manager_per_rest() returns trigger as
     $$
     begin
        if((select count(*) from restaurant_managers where restaurant = old.restaurant) <= 1) then
            raise exception 'Restaurant needs at least one manager';

        end if;
        return old;
     end;
     $$language plpgsql;

create or replace trigger check_manager_per_rest
    before delete on restaurant_managers
    for each row
    execute function manager_per_rest();