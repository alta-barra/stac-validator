import Config

config :ex_json_schema,
       :remote_schema_resolver,
       fn url -> HTTPoison.get!(url).body |> Jason.decode!() end