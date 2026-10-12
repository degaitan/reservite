set search_path to public;

/*
     End points restaurant
 */

create or replace function get_matching_restaurants(filter varchar)
    returns table
        (id int,
        name varchar,
        address varchar,
        city varchar,
        phone varchar,
        description text,
        rating double precision,
        price_range int,
        slot_duration int,
        latest_reservation timestamp) as
$$
     declare substr varchar;
     begin
         perform auth.check_logged();
         substr = '%' || lower(filter) || '%';
         return query
             select r.id, r.name, r.address, r.city, r.phone, r.description,
                    r.rating, r.price_range, r.slot_duration,
                    (select max(res.datetime) from reservations res
                     where res.restaurant = r.id and res.client = auth.id()) as latest_reservation
             from restaurants r
             where (lower(r.name) like substr
                 or lower(r.description) like substr
                 or lower(r.city) like substr)
             order by latest_reservation desc nulls last;
     end;
$$ language plpgsql security definer;

grant execute on function get_matching_restaurants(filter varchar) to authenticated;

create or replace function get_my_restaurants()
    returns table
        (id int,
         name varchar,
         address varchar,
         city varchar,
         phone varchar,
         description text,
         rating double precision,
         price_range int,
         slot_duration int,
         latest_reservation timestamp) as
$$
    begin
        perform auth.check_logged();
        return query
        select r.id, r.name, r.address, r.city, r.phone, r.description,
               r.rating, r.price_range, r.slot_duration,
               (select max(res.datetime) from reservations res where res.restaurant = r.id) as latest_reservation
        from restaurants r
        where r.id in (select rm.restaurant from restaurant_managers rm where rm.manager = auth.id())
        order by latest_reservation desc nulls last;
        /*
         sans le nulls last, les restos sans reservations ne se mettent pas en fin de liste
         */
    end;
$$ language plpgsql security definer;

grant execute on function get_my_restaurants() to manager;

create or replace function get_pending_count_per_restaurant(_resto_id int) returns int as
    $$
    declare
        _count int;
    begin
        select count(*) into _count from reservations r where r.restaurant = _resto_id and  r.status = 'pending'::status_type;
        return _count;
    end;
    $$language plpgsql security definer ;
grant execute on function get_pending_count_per_restaurant to manager;



-- select * from get_matching_restaurants('BRU');