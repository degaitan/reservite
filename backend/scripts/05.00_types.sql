set search_path to public;

drop type if exists no_slots_reason cascade;
create type no_slots_reason as enum (
    'closed',
    'already_booked_service',
    'no_capacity'
    );