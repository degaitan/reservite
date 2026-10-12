set search_path to public;

/*
 ==========================================

(BR-08) Au moment de leur création ou de leur modification, les heures de début et de fin d'un service doivent être
    alignées sur les créneaux de réservation pour le restaurant.

 ==========================================
 */

    create or replace function service_time() returns trigger as
        $$
            begin
                if exists(select *
                          from services s, restaurants r
                          where r.id = s.restaurant and (extract(minute from s.end_time)%r.slot_duration <>0 or extract(minutes from s.start_time)%r.slot_duration <>0)) then
                    raise exception 'Service times do not match respective restaurant slots';
                end if;
                return null;
            end;
        $$language plpgsql;

create or replace trigger check_service_time_on_service
    after insert or update on services
    for each row
    execute function service_time();

create or replace trigger check_service_time_on_restaurant
    after insert or update on restaurants
    for each row
execute function service_time();

/*insert into services (restaurant, day_of_week, start_time, end_time)
values (2, 1, '12:17', '14:00');

insert into services (restaurant, day_of_week, start_time, end_time)
values (2, 3, '18:07', '22:30');*/