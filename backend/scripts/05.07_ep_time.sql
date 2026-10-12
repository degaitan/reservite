set search_path to public;

/*
     End point system_time
 */

    create or replace function get_simulated_time() returns timestamp as
        $$
        declare
            _new_time timestamp;
        begin
            select system_time.simulated_time into _new_time from system_time limit 1;
            return _new_time;
        end;
        $$language plpgsql security definer ;

grant execute on function get_simulated_time to authenticated;
grant execute on function get_simulated_time to anon;


create or replace function save_simulated_time(_timestamp timestamp) returns void as
    $$
    begin
        /*
         si on peut avoir plusieurs lignes dans la table, on delete la table d'abord mais pas sure
         */
        delete from system_time;
        insert into system_time (simulated_time) values (_timestamp);
    end;
    $$language plpgsql security definer ;

grant execute on function save_simulated_time(timestamp) to authenticated;
grant execute on function save_simulated_time to anon;

