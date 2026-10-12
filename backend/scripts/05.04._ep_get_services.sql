set search_path to public;

/*
     End point get_services
 */

 create or replace function get_services(restaurant_id int)
 returns table (
     id INTEGER,
     restaurant INTEGER,
     day_of_week INTEGER,
     start_time TIME,
     end_time TIME )
 as
$$
     begin
         return query
         select * from services where services.restaurant = restaurant_id;
     end;
$$ language plpgsql security definer;

grant execute on function get_services(restaurant_id int) to authenticated;

create or replace function set_service(service_id int, new_day_of_week int, new_start_time time, new_end_time time)
    returns void as
$$
begin
    perform auth.check_logged();
    update services
    set
        day_of_week = new_day_of_week,
        start_time = new_start_time,
        end_time = new_end_time
    where id = service_id;
end;
$$ language plpgsql security definer;


grant execute on function set_service(service_id int, new_day_of_week int, new_start_time time, new_end_time time) to manager;

create or replace function add_service(restaurant_id int, week_day int, new_start_time TIME, new_end_time TIME)
returns void as
$$
    begin
        insert into services (restaurant, day_of_week, start_time, end_time) VALUES (restaurant_id, week_day, new_start_time, new_end_time);
    end;
$$ language plpgsql security definer;

grant execute on function add_service(restaurant_id int, week_day int, new_start_time TIME, new_end_time TIME) to manager;

create or replace function delete_service(service_id int)
    returns void as
$$
begin
    perform auth.check_logged();

    delete from services
    where id = service_id;
end;
$$ language plpgsql security definer;

grant execute on function delete_service(service_id int) to manager;