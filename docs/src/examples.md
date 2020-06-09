```@meta
CurrentModule = PCloud
```

# Usage examples

Here you can find different snippets which can help in building fast and simple data pipelines with the usage of [PCloud.jl](https://github.com/Arkoniak/PCloud.jl). These snippets are not the best possible ways to solve problems, but they can be used as a starting point. Also they illustrate ways how to apply various Julia techniques such as broadcasting and anonymous functions together with `pCloud` to achieve goals without too much efforts.

## Uploading and downloading CSV
CSV is rather common format for storing data, and [CSV.jl](https://github.com/JuliaData/CSV.jl) provides convenient function `CSV.write` which can store data in `IOBuffer` which in turn can be uploaded to `pCloud`.

Let's create `DataFrame`
```julia
using CSV
using DataFrames
using Random

df = DataFrame(x = rand(10), y = rand(1:10, 10), z = [randstring(5) for _ in 1:10])
# 10×3 DataFrame
# │ Row │ x         │ y     │ z      │
# │     │ Float64   │ Int64 │ String │
# ├─────┼───────────┼───────┼────────┤
# │ 1   │ 0.0756344 │ 6     │ H3BIk  │
# │ 2   │ 0.396882  │ 5     │ Rv2SB  │
# │ 3   │ 0.797529  │ 5     │ M61Hw  │
# │ 4   │ 0.856915  │ 5     │ jLc7K  │
# │ 5   │ 0.0120147 │ 1     │ HgZMA  │
# │ 6   │ 0.493593  │ 3     │ ENfu3  │
# │ 7   │ 0.27618   │ 2     │ MIU5B  │
# │ 8   │ 0.492329  │ 10    │ QflU7  │
# │ 9   │ 0.398613  │ 10    │ 4XioP  │
# │ 10  │ 0.40273   │ 10    │ PQs14  │
```

To store this dataframe in `pCloud` we write it's contents to `IOBuffer` and upload resulting buffer to `pCloud` with the help of [`uploadfile`](@ref) function
```julia
using PCloud
using PCloud: uploadfile, getfilelink

token = # HERE SHOULD BE YOUR TOKEN
client = PCloudClient(auth_token = token)

buffer = CSV.write(IOBuffer, df)
res = uploadfile(client, files = "data.csv" => buf)
```

Returned reponse `res` contains necessary information about resulting file. And to get it back we can use [`getfilelink`](@ref)

```julia
using UrlDownload
using Underscores

df2 = @_ getfilelink(client, fileid = first(res.fileids)) |>
    urldownload("https://" * first(__.hosts) * __.path) |> DataFrame
# 10×3 DataFrame
# │ Row │ x         │ y     │ z      │
# │     │ Float64   │ Int64 │ String │
# ├─────┼───────────┼───────┼────────┤
# │ 1   │ 0.0756344 │ 6     │ H3BIk  │
# │ 2   │ 0.396882  │ 5     │ Rv2SB  │
# │ 3   │ 0.797529  │ 5     │ M61Hw  │
# │ 4   │ 0.856915  │ 5     │ jLc7K  │
# │ 5   │ 0.0120147 │ 1     │ HgZMA  │
# │ 6   │ 0.493593  │ 3     │ ENfu3  │
# │ 7   │ 0.27618   │ 2     │ MIU5B  │
# │ 8   │ 0.492329  │ 10    │ QflU7  │
# │ 9   │ 0.398613  │ 10    │ 4XioP  │
# │ 10  │ 0.40273   │ 10    │ PQs14  │
```

### Working with comressed CSV

Since csv files can be rather large it is a common practice to compress them before uploading. It can be done as follows (assuming the same `df` from the previous example)

```julia
using CodecZlib

buf = CSV.write(IOBuffer(), df) |> seekstart |> GzipCompressorStream
res = uploadfile(client, files = "data.csv.gz" => buf)
```

Note that we should use `seekstart` here, since after `IOBuffer` is written, it's pointer located at the end and subsequent reading of the buffer in [`uploadfile`](@ref) return empty array. Also, in this exampe we used `GzipCompressorStream`, but any other compressing algorithm can be used, refer [TranscodingStreams.jl](https://github.com/JuliaIO/TranscodingStreams.jl#codec-packages).

And to verify the result of upload

```julia
using UrlDownload
using Underscores

df2 = @_ getfilelink(client, fileid = first(res.fileids)) |> 
   urldownload("https://" * first(__.hosts) * __.path) |> DataFrame 
# 10×3 DataFrame
# │ Row │ x         │ y     │ z      │
# │     │ Float64   │ Int64 │ String │
# ├─────┼───────────┼───────┼────────┤
# │ 1   │ 0.0756344 │ 6     │ H3BIk  │
# │ 2   │ 0.396882  │ 5     │ Rv2SB  │
# │ 3   │ 0.797529  │ 5     │ M61Hw  │
# │ 4   │ 0.856915  │ 5     │ jLc7K  │
# │ 5   │ 0.0120147 │ 1     │ HgZMA  │
# │ 6   │ 0.493593  │ 3     │ ENfu3  │
# │ 7   │ 0.27618   │ 2     │ MIU5B  │
# │ 8   │ 0.492329  │ 10    │ QflU7  │
# │ 9   │ 0.398613  │ 10    │ 4XioP  │
# │ 10  │ 0.40273   │ 10    │ PQs14  │
```

## Uploading generated image

In this example we will use [Luxor.jl](https://github.com/JuliaGraphics/Luxor.jl) for image generation and also use [`getfilepublink`](@ref) to generate public link to the resulting image.

```julia
using Luxor

d = Drawing(600, 400, :png)
origin()
background("white")
for θ in range(0, step=π/8, length=16)
    gsave()
    scale(0.25)
    rotate(θ)
    translate(250, 0)
    randomhue()
    julialogo(action=:fill, color=false)
    grestore()
end

gsave()
scale(0.3)
juliacircles()
grestore()

translate(200, -150)
scale(0.3)
julialogo()
finish()
```

Please notice, that we used `:png` keyword in `Drawing` definition, to force in-memory image processing.

```julia
using PCloud
using PCloud: uploadfile, getfilepublink

token = # HERE SHOULD BE YOUR TOKEN
client = PCloudClient(auth_token = token)

res = uploadfile(client, files = "logo.png" => d.buffer)

getfilepublink(client, fileid = first(res.fileids)).link
# "https://u.pcloud.link/publink/show?code=XZh8FEkZ6vBed7DI1Wys8g7BHl8FFVuhUSSX"
```
If you follow this [link](https://u.pcloud.link/publink/show?code=XZh8FEkZ6vBed7DI1Wys8g7BHl8FFVuhUSSX), you can see that it is valid png file.

## Project Gutenberg and `downloadfile`

Method [`PCloud.downloadfile`](@ref) can download file from urls directly to pCloud. This can be very useful during web crawling, when various information of interest should be saved for further investigation. As an example we download 10 top books from [Project Gutenberg](https://www.gutenberg.org/)
```julia
using Underscores
using Gumbo
using Cascadia
using Cascadia: matchFirst
using UrlDownload
using PCloud
using PCloud: createfolder, downloadfile

token = # HERE SHOULD BE YOUR TOKEN
client = PCloudClient(auth_token = token)

# folder where books will be stored
folderid = createfolder(client, folderid = 0, name = "Gutenberg").metadata.folderid

host = "https://www.gutenberg.org"

# helper function for parsing data downloaded by `urldownload` to a more useful format
pageparser(x) = parsehtml(String(x)).root

# helper function which finds download url on each book page
# should be used for parsing each individual book page, for example
# getlink("https://www.gutenberg.org/ebooks/1342") would produce url to
# "Pride and Prejudice" in epub format.
getlink(url) = @_ urldownload(url, parser = pageparser) |>
    host*matchFirst(sel"a[type='application/epub+zip']", __).attributes["href"]
    
# This is central function, which parses top scores page, extract top 10 books,
# extract download url for each book with the help of `getlink` and finally
# download everything to pCloud
@_ urldownload("https://www.gutenberg.org/browse/scores/top", parser = pageparser) |>
    matchFirst(sel"ol", __) |> eachmatch(sel"li", __)[1:10] |>
    matchFirst.(Ref(sel"a"), __) |> map(host*_.attributes["href"], __) |>
    getlink.(__) |> join(__, " ") |>
    downloadfile(client, url = __, folderid = folderid)
```
