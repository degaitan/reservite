set search_path to public;

/*
 End points pour récupérer les informations d'un client
 */

DROP FUNCTION if exists get_user_by_name(character varying);

create or replace function get_user_by_name(user_name varchar)
    returns table (
        id int,
        email varchar,
        name varchar,
        role role_type,
        phone varchar
        ) as
$$
    begin
        perform auth.check_logged();
        return query
        select u.id, u.email, u.full_name, u.role, u.phone from users u where lower(u.full_name) = lower(user_name);
    end;
$$ language plpgsql security definer;

grant execute on function get_user_by_name(user_name varchar) to manager;