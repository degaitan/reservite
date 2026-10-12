set search_path to public;

/*
 ==========================================
 TABLE USERS
 ==========================================
 */

 alter table users drop constraint if exists name_length;

alter table users add constraint name_length
check ( length(trim(users.full_name)) >= 3 ) NOT VALID;


alter table users add constraint password_format
check (users.password ~ '^\$2[aby]\$\d{2}\$[./A-Za-z0-9]{53}$'
          OR
          users.password ~ '^(?=.*\d)(?=.*[A-Z])(?=.*[a-z])(?=.*[,;.:!?/$%&@#]).{8,}$'
      ) NOT VALID;

/*
 ==========================================
 TABLE RESTAURANTS
 ==========================================
 */
alter table restaurants drop constraint if exists name_length;

alter table restaurants add constraint name_length
check ( length(trim(restaurants.name)) >= 5 ) not valid;

alter table restaurants drop constraint if exists address_length;

alter table restaurants add constraint address_length
    check ( length(trim(restaurants.address)) >= 5 ) not valid;

alter table restaurants drop constraint if exists city_length;

alter table restaurants add constraint city_length
    check ( length(trim(restaurants.city)) >= 3 ) not valid;

alter table restaurants drop constraint if exists check_phone_number_format;

alter table restaurants add constraint check_phone_number_format
    check ( restaurants.phone ~ '^\+32\s?\d{1,3}(?:\s?\d{2,3}){2,3}$' ) not valid;
/*check ( restaurants.phone ~ '^0\d(?:\s?\d{3})(?:\s?\d{2}){2}$' || restaurants.phone ~ '^0\d{2}(?:\s?\d{2}){3}$' ||
    restaurants.phone ~ '^04\d{2}(?:\s?\d{2}){3}$') not valid;*/

alter table restaurants drop constraint if exists description_length;

alter table restaurants add constraint description_length
    check ( restaurants.description is null or length(trim(restaurants.description)) >= 10)  not valid;

alter table restaurants drop constraint if exists rating_check;

alter table restaurants add constraint rating_check
    check ( restaurants.rating is null or (restaurants.rating >= 0.0 and restaurants.rating <= 5.0)) not valid;

alter table restaurants drop constraint if exists price_range_check;

alter table restaurants add constraint price_range_check
    check ( restaurants.price_range is null or (restaurants.price_range >= 1 and restaurants.price_range <= 4) ) not valid;

alter table restaurants drop constraint if exists slot_check;

alter table restaurants add constraint slot_check
    check ( restaurants.slot_duration in (10, 15, 20, 30, 60) ) not valid;

/*
 ==========================================
 TABLE TABLES
 ==========================================
 */

/*alter table tables
    drop constraint if exists nb_table_unique;

alter table tables
    add constraint nb_table_unique unique (table_number) ;*/

alter table tables
    drop constraint if exists nb_table_value;

alter table tables
    add constraint nb_table_value
        check (tables.table_number >0);

alter table tables
    drop constraint if exists capacity_check;

alter table tables
    add constraint capacity_check
    check(tables.capacity>0) not valid;

/*
 ==========================================
 TABLE SERVICES
 ==========================================
 */

alter table services drop constraint if exists day_of_week_check;

alter table services add constraint day_of_week_check
check ( services.day_of_week >= 1 and services.day_of_week <= 7 ) not valid;


alter table services drop constraint if exists end_time_check;

alter table services add constraint end_time_check
check ( services.end_time - services.start_time >= interval '1 hour' ) not valid;

/*
 ==========================================
 TABLE RESERVATIONS
 ==========================================
 */

 /*
  nombre de convives d'un resa doit être >0
  */
 ALTER TABLE reservations DROP CONSTRAINT IF EXISTS capacity_check;

 alter table reservations add constraint capacity_check
 check ( number_of_guests > 0) not valid;

/*
 s'il y a une special request, sa longueur doit être >10
 */
ALTER TABLE reservations DROP CONSTRAINT IF EXISTS special_request_check;

ALTER TABLE reservations add constraint special_request_check
check(
    special_requests IS NULL or (length(trim(special_requests)) >= 10)
    ) not valid;


/*
 Statut resa doit appartenir au enum
 */

ALTER TABLE reservations DROP CONSTRAINT IF EXISTS status_check;


alter table reservations add constraint status_check
 check( status in ('pending'::status_type, 'confirmed'::status_type, 'cancelled'::status_type, 'completed'::status_type)) not valid;