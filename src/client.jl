struct PCloudError{T} <: Exception
    msg::T
end

function PCloudClient(; auth_token = "", user = "", password = "", set_endpoints = true)
    client = PCloudClient("https://api.pcloud.com/",
                          "https://api.pcloud.com/",
                          "https://api.pcloud.com/",
                          Dict{String, String}())
    if !isempty(auth_token)
        authorize!(client, auth_token)
    elseif !isempty(user) & !isempty(password)
        authorize!(client, user, password)
    end

    if set_endpoints
        update_endpoints!(client)
    end

    return client
end

function authorize!(client::PCloudClient, auth_token)
    client.cookies["auth"] = auth_token
end

function authorize!(client::PCloudClient, user, password)
    digest_json = getdigest(client)
    digest = digest_json.digest
    pwddigest = bytes2hex(sha1(password * bytes2hex(sha1(user)) * digest))
    res = userinfo(client; getauth = 1, logout = 1, username = user,
                   digest = digest, passworddigest = pwddigest)
    client.cookies["auth"] = res.auth
end

function authtoken(client::PCloudClient)
    return client.cookies["auth"]
end

function update_endpoints!(client::PCloudClient)
    res = API.getapiserver(client)
    client.apiep = "https://" * first(res.api) * "/"
    client.binep = "https://" * first(res.binapi) * "/"

    return client
end

function reset_endpoints!(client::PCloudClient)
    client.apiep = client.rootep
    client.binep = client.rootep

    return client
end

function useglobally!(client::PCloudClient)
    OPTS.client = client
end
