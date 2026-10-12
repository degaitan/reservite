begin;
do
$test$
    begin
        raise notice 'TEST: Créneaux qui se chevauchent';

        perform should_fail($$
            insert into services (restaurant, day_of_week, start_time, end_time) values (1, 1, '19:30:00', '21:00:00')
        $$);
    end
$test$;
rollback;
