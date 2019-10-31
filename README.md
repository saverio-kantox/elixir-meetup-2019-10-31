# ExMeetup

## Step 1 - generating schemas

- `mix phx.gen.html Admin User users name:string email:string --binary-id`
- `mix phx.gen.html Admin Payment payments amount:decimal currency:string value_date:date state:string user_id:references:users --binary-id`
