set search_path to public;

/*
 End points singup
 */


create or replace function check_email_available(email text)
       returns boolean as
       $$
    begin
        return not exists(select 1 from users where trim(lower(users.email)) = trim(lower(check_email_available.email)));
    end;
       $$language plpgsql security definer ;

grant execute on function check_email_available to anon;


create or replace function check_full_name_available(full_name text)
       returns boolean as
    $$
    begin
        return not exists(select 1 from users where trim(lower(users.full_name)) = trim(lower(check_full_name_available.full_name)));
    end;
    $$language plpgsql security definer ;

grant execute on function check_full_name_available to anon;


create or replace function save_user(_full_name text, _email text, _password text, _phone text default null)
    returns void as
    $$
    begin
        insert into users (email, password, full_name, role, phone) values (_email, _password, _full_name, 'client', _phone);
    end;
    $$language plpgsql security definer ;

grant execute on function save_user to anon;


select save_user('Test', 'test@example.com', 'Password1,');

select id, email, full_name, role, phone from users where email = 'test@example.com';

delete from users where email = 'test@example.com';

create or replace function is_client() returns bool as
    $$
    begin
        return auth.role() = 'client';
    end;
    $$language plpgsql;

create or replace function is_manager() returns bool as
    $$
    begin
        return auth.role() = 'manager';
    end;
    $$language plpgsql;

create or replace function is_manager_to_restaurant(resto_id int) returns bool as
    $$
    begin
        return exists(
            select 1
            from restaurant_managers rm
            where rm.manager = auth.id() and rm.restaurant = resto_id
        );
    end;
    $$language plpgsql;

grant execute on function is_client to authenticated;
grant execute on function is_manager to authenticated;
grant execute on function is_manager_to_restaurant to authenticated;