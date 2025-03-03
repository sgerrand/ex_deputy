ExUnit.start()

Mox.defmock(Deputy.HTTPClient.Mock, for: Deputy.HTTPClient.Behaviour)

Application.put_env(:deputy, :http_client, Deputy.HTTPClient.Mock)
