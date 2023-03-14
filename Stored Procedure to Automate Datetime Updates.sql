/*
When working with databases, it's important to keep track of when data is updated or inserted. 
One common way to do this is to have a column in your table that records the time of the last update. 
However, manually updating this column every time you insert or update data can be tedious and error-prone. 
That's where stored procedures and triggers come in.

Here is an example that sets up a trigger to automatically update the datetime column of a row whenever 
an update operation is performed on the table. The stored procedure is used to define the functionality of the trigger.
*/

--table
CREATE TABLE transaction (
    id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

--Add sample data into table 
insert into transaction (account_id, amount)
values (1,1);

-- Store procedure
create or replace function trigger_set_timestamp()
returns trigger as $$
begin
new.updated_at=now();
return new;
end;
$$ language plpgsql;

-- Create trigger
create trigger set_timestamp
before update on transaction
for each row
execute procedure trigger_set_timestamp();

--update statement after the trigger was added:
update transaction 
set amount=amount+1
where account_id = 1
returning *;

--update statement without the trigger, requires manual input:
update concurrency 
set howmuch=howmuch+1,
updated_at=now()
where account_id = 1
returning *;
