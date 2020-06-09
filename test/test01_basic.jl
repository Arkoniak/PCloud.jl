module TestBasic
using PCloud
using Test

@testset "client creation" begin
    pcloud = PCloudClient()

    res = PCloud.getdigest(pcloud)
    @test res.result == 0
end

@testset "client endpoints" begin
    pcloudapi = "https://api.pcloud.com/"
    pcloud = PCloudClient(set_endpoints = false)

    @test pcloud.apiep == pcloudapi
    @test pcloud.binep == pcloudapi
    @test pcloud.rootep == pcloudapi

    res = PCloud.getapiserver(pcloud)
    update_endpoints!(pcloud)
    @test pcloud.apiep == "https://" * first(res.api) * "/"
    @test pcloud.binep == "https://" * first(res.binapi) * "/"
    @test pcloud.rootep == pcloudapi

    reset_endpoints!(pcloud)
    @test pcloud.apiep == pcloudapi
    @test pcloud.binep == pcloudapi
    @test pcloud.rootep == pcloudapi
end

@testset "client authentication" begin
    @test_throws PCloud.PCloudError PCloudClient(user = "nouser", password = "nopassword")
    pcloud = PCloudClient(auth_token = "notoken")
    @test_throws PCloud.PCloudError userinfo(pcloud)
end

end # module
