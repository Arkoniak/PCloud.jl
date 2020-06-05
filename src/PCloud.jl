module PCloud
using HTTP
using JSON3
using SHA

include("pcloud_api.jl")

export authorize!, PCloudClient

struct PCloudError{T} <: Exception
    msg::T
end

struct PCloudClient
    endpoint::String
    cookies::Dict{String, String}
end

function PCloudClient(; auth_token = "", user = "", password = "")
    client = PCloudClient("https://api.pcloud.com/", Dict{String, String}())
    if !isempty(auth_token)
        authorize!(client, auth_token)
    elseif !isempty(user) & !isempty(password)
        authorize!(client, user, password)
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

function query(client::PCloudClient, method, params)
    uri = client.endpoint * method * "?" * HTTP.URIs.escapeuri(params)
    res = JSON3.read(String(HTTP.get(uri, cookies = client.cookies).body))
    if res.result == 0
        return res
    else
        throw(PCloudError(res))
    end
end

for (f, fdoc) in PCLOUD_API
    @eval begin
        $f(client::PCloudClient; kwargs...) = query(client, String(Symbol($f)), Dict(kwargs))
        @doc $fdoc $f
        export $f
    end
end
# for method in [ # General https://docs.pcloud.com/methods/general/
#                :getdigest, :userinfo, :supportedlanguages,
#                :setlanguage, :feedback, :currentserver,
#                :diff, :getfilehistory, :getip, :getapiserver,

#                 # Folder https://docs.pcloud.com/methods/folder/
#                :createfolder, :createfolderifnotexists, :listfolder,
#                :renamefolder, :deletefolder, :deletefolderrecursive,
#                :copyfolder,

#                 # Auth https://docs.pcloud.com/methods/auth/
#                :sendverificationemail, :verifyemail, :changepassword,
#                :lostpassword, :resetpassword, :register, :invite,
#                :userinvites, :logout, :listtokens, :deletetoken,
#                :sendchangemail, :changemail, :senddeactivatemail,
#                :deactivateuser,

#                 # Newsletter https://docs.pcloud.com/methods/newsletter/
#                :newsletter_subscribe, :newsletter_check, :newsletter_verifyemail,
#                :newsletter_unsubscribe, :newsletter_unsibscribemail,

#                 # Trash https://docs.pcloud.com/methods/trash/
#                :trash_list, :trash_restorepath, :trash_restore, :trash_clear
#               ]
#     @eval $method(client::PCloudClient; kwargs...) = query(client, String(Symbol($method)), Dict(kwargs))
#     @eval export $method
# end

end # module
