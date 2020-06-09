const PCLOUD_API = [
(:getdigest, """
	getdigest(client::PCloudClient; kwargs...)

Returns a digest for digest authentication. Digests are valid for 30 seconds.

Source: https://docs.pcloud.com/methods/general/getdigest.html

# Output

- `digest::String`: the digest for authentication

- `expires::datetime`: when the digest expires

# Output Example
```
{
    result: 0,
    digest: "YGtAxbUpI85Zvs7lC7Z62rBwv907TBXhV2L867Hkh",
    expires: "Fri, 27 Sep 2013 10:15:46 +0000"
}
```
"""),
(:userinfo, """
	userinfo(client::PCloudClient; kwargs...)

Returns information about the current user. As there is no specific `login` method as credentials can be passed to any method, this is an especially good place for logging in with no particular action in mind.

Source: https://docs.pcloud.com/methods/general/userinfo.html

# Output

- `email::String`: email address of the user

- `emailverified::Bool`: true if the user had verified it's email

- `registered::datetime`: when the user was registerd

- `premium::Bool`: true if the user is premium

- `premiumexpires::datetime`: if premium is true: premiumexpires will be the date until the service is

- `quota::Int`: in bytes

- `usedquota::Int`: in bytes, so quite big numbers

- `language::String`: 2-3 characters lowercase languageid

# Output Example
```
{
    result: 0, 
    userid: 1234,
  email: pcloud@pcloud.com,
  emailverified: true,
  registered: "Mon, 18 Nov 2013 15:32:05 +0000",
  language: "en",
    premium: false,
  usedquota: 500,
  quota: 1000    
}
```
"""),
(:supportedlanguages, """
	supportedlanguages(client::PCloudClient; kwargs...)

Lists supported languages in the returned `languages` hash, where keys are language codes and values are languages names

Source: https://docs.pcloud.com/methods/general/supportedlanguages.html

# Output Example
```
{
    result: 0,
    languages: {
        en: "English",
        ...
    }
}
```
"""),
(:setlanguage, """
	setlanguage(client::PCloudClient; kwargs...)

Sets user's language to `language`.

Source: https://docs.pcloud.com/methods/general/setlanguage.html

# Arguments

- `language::String`: the language to be set

# Output Example
```
{
    result: 0
}
```
"""),
(:feedback, """
	feedback(client::PCloudClient; kwargs...)

Sends message to pCloud support

Source: https://docs.pcloud.com/methods/general/feedback.html

# Arguments

- `mail::String`: email of the user

- `reason::String`: subject of the request

- `message::String`: the message itself

# Optional Arguments

- `name::String`: can be provided with users full name

# Output Example
```
{
    result: 0
}
```
"""),
(:currentserver, """
	currentserver(client::PCloudClient; kwargs...)

Returns `ip` and `hostname` of the server you are currently connected to. The hostname is guaranteed to resolve only to the IP address(es) pointing to the same server. This call is useful when you need to track the upload progress.

Source: https://docs.pcloud.com/methods/general/currentserver.html

# Output

- `ip::String`: IP v.4 address of the server

- `ipbin::String`: IP v.4 address

- `ipv6::String`: IP v.6 address of the server

- `hostname::String`: hostname of the server

# Output Example
```
{
    ipv6: "::1",
    hostname: "api7.pcloud.com",
    ip: "204.155.155.21",
    result: 0,
    ipbin: "204.155.155.60"
}
```
"""),
(:diff, """
	diff(client::PCloudClient; kwargs...)

List updates of the user's folders/files.

Optionally, takes the parameter `diffid`, which if provided returns only changes since that `diffid`.

Alternatively you can provide date/time in `after` parameter and you will only receive events generated after that time.

Another alternative to providing `diffid` or `after` is providing `last`, which will return `last` number of events with highest diffids (that is the last events).

Especially setting `last` to 0 is optimized to do nothing more than return the last `diffid`.

If the optional parameter `block` is set and there are no changes since the provided `diffid`, the connection will block until an event arrives. Blocking only works when `diffid` is provided and does not work with either `after` or `last`.

However, sending any additional data on the blocked connection will unblock the request and an empty set will be returned. This is useful when you want to monitor for updates when idle and use connection for other activities when needed.

Just keep in mind that if you send any request on a connection that is blocked, you will receive two replies - one with empty set of updates and one answering your second request.

If the optional `limit` parameter is provided, no more than `limit` entries will be returned.

*IMPORTANT* When a folder/file is created/delete/moved in or out of a folder, you are supposed to update modification time of the parent folder to the timestamp of the event.

*IMPORTANT* If your state is more than 6 months old, you are advised to re-download all your state again, as we reserve the right to compact data that is more than 6 months old.

Compacting means that if a deletefolder/deletefile event is more than 6 month old, it will disappear altogether with all create/modify events. Also, if modifyfile is more than 6 months old, it can become createfile and the original createfile will disappear. That is not comprehensive list of compacting activities, so you should generally re-download from zero rather than trying to cope with compacting.

Source: https://docs.pcloud.com/methods/general/diff.html

# Optional Arguments

- `diffid::Int`: receive only changes since that diffid.

- `after::datetime`: receive only events generated after that time

- `last::Int`: return last number of events with highest diffids (that is the last events)

- `block::Int`: if set, the connection will block until an event arrives. Works only with diffid

- `limit::Int`: if provided, no more than limit entries will be returned

# Output

On success in the reply there will be `entries` array of objects and `diffid`. Set your current `diffid` to the provided `diffid` after you process all events, during processing set your state to the `diffid` of the event preferably in a single transaction with the event itself.

Each object will have at least:

- `diffid::Int`: the event's identificator

- `time::datetime`: timestamp of the event

- `event::event`: see the possible events here

In most cases also metadata will be provided.

`diffid` could be used to request updates since this event. Normally diffids are incrementing integers, but one can not assume that ids are consecutive as events that cancel each other (e.g. createfolder, deletefolder) are not displayed if they happen to be in the same list.

For shares, a share object is provided.

`time` of the event is the time of the event - even if the event is createfolder, `time` is not guaranteed to be the folder's creation time. The folder might be somebody elses folder,created an year ago, that was just shared with you.
"""),
(:getfilehistory, """
	getfilehistory(client::PCloudClient; kwargs...)

Returns event history of a file identified by `fileid`. File might be a deleted one. The output format is the same as of diff method.

Source: https://docs.pcloud.com/methods/general/getfilehistory.html

# Arguments

- `fileid::Int`: fileid of a file that history is requested for

# Output Example
```
{
  "result": 0,
  "entries": [
    {
      "event": "createfile",
      "time": "Mon, 14 Oct 2013 03:24:43 +0000",
      "diffid": 13924,
      "metadata": {
        "isshared": true,
        "thumb": false,
        "contenttype": "video/mp4",
        "size": 0,
        "category": 2,
        "hash": 14841775194319522618,
        "parentfolderid": 397140,
        "modified": "Mon, 14 Oct 2013 03:24:43 +0000",
        "isfolder": false,
        "created": "Mon, 14 Oct 2013 03:24:43 +0000",
        "fileid": 2712167,
        "id": "f2712167",
        "icon": "video",
        "name": "GOPR0002.MP4",
        "ismine": true
      }
    },
    {
      "event": "modifyfile",
      "time": "Mon, 14 Oct 2013 04:07:25 +0000",
      "diffid": 13927,
      "metadata": {
        "isshared": true,
        "thumb": true,
        "contenttype": "video/mp4",
        "size": 1993278633,
        "category": 2,
        "hash": 4322830267003041431,
        "parentfolderid": 397140,
        "modified": "Mon, 14 Oct 2013 04:07:25 +0000",
        "isfolder": false,
        "created": "Mon, 14 Oct 2013 03:24:43 +0000",
        "fileid": 2712167,
        "id": "f2712167",
        "icon": "video",
        "name": "GOPR0002.MP4",
        "ismine": true
      }
    }
  ]
}
```
"""),
(:getip, """
	getip(client::PCloudClient; kwargs...)

Get the IP address of the remote device from which the user connects to the API.

Source: https://docs.pcloud.com/methods/general/getip.html

# Output

Returns `ip` - the remote address of the user that is connecting to the API.

Also, returns `country` - lowercase two-letter code of the country that is defined according to the remote address. If the country could not be defined, then this fields is `false`.

# Output Example
```
{
  "result": 0,
  "ip": "127.0.0.1",
  "country": "gb"
  ]
}
```
"""),
(:getapiserver, """
	getapiserver(client::PCloudClient; kwargs...)

This method returns closest API server to the requesting client. The biggest speed gain will be with upload methods. Clients should have fallback logic. If request to API server different from api.pcloud.com fails (network error) the client should fallback to using api.pcloud.com.

Source: https://docs.pcloud.com/methods/general/getapiserver.html

# Output

binapi - array with API servers that support connections via pCloud's binary protocol

api - array with API servers that support connections via HTTP/HTTPS protocol

# Output Example
```
{
  "result": 0,
  "binapi": [
    "binapi-ams1.pcloud.com"
  ],
  "api": [
    "api-ams1.pcloud.com"
  ]
}
```
"""),
(:createfolder, """
	createfolder(client::PCloudClient; kwargs...)

Creates a folder.

Expects either `path` string parameter (discouraged) or int `folderid` and string `name` parameters.

Source: https://docs.pcloud.com/methods/folder/createfolder.html

# Arguments

- `path::String`: path to the folder(discouraged)

- `folderid::Int`: id of the folder

- `name::String`: name of the folder

Use `path` or `folderid` + `name`

# Output

Upon success returns `metadata` structure.

# Output Example
```
{
    "result": 0,
    "metadata": {
        "created": "Wed, 02 Oct 2013 13:11:53 +0000",
        "isfolder": true,
        "parentfolderid": 0,
        "icon": "folder",
        "id": "d230807",
        "path": "/new folder",
        "modified": "Wed, 02 Oct 2013 13:11:53 +0000",
        "thumb": false,
        "folderid": 230807,
        "isshared": false,
        "ismine": true,
        "name": "New folder"
    }
}
```
"""),
(:createfolderifnotexists, """
	createfolderifnotexists(client::PCloudClient; kwargs...)

Creates a folder if the folder doesn't exist or returns the existing folder's metadata.

Expects either `path` string parameter (discouraged) or int `folderid` and string `name` parameters.

Source: https://docs.pcloud.com/methods/folder/createfolderifnotexists.html

# Arguments

- `path::String`: path to the folder(discouraged)

- `folderid::Int`: id of the folder

- `name::String`: name of the folder

Use `path` or `folderid` + `name`

# Output

Upon success returns `metadata` structure.

# Output Example
```
{
    "result": 0,
    "created": true,
    "metadata": {
        "created": "Wed, 02 Oct 2013 13:11:53 +0000",
        "isfolder": true,
        "parentfolderid": 0,
        "icon": "folder",
        "id": "d230807",
        "path": "/new folder",
        "modified": "Wed, 02 Oct 2013 13:11:53 +0000",
        "thumb": false,
        "folderid": 230807,
        "isshared": false,
        "ismine": true,
        "name": "New folder"
    }
}
```
"""),
(:listfolder, """
	listfolder(client::PCloudClient; kwargs...)

Receive data for a folder.

Expects folderid or path parameter, returns folder's `metadata`. The metadata will have `contents` field that is array of metadatas of folder's contents.

Recursively listing the root folder is not an expensive operation.

Source: https://docs.pcloud.com/methods/folder/listfolder.html

# Arguments

- `path::String`: path to the folder(discouraged)

- `folderid::Int`: id of the folder

Use `path` or `folderid`

# Optional Arguments

- `recursive::Int`: If is set full directory tree will be returned, which means that all directories will have contents filed.

- `showdeleted::Int`: If is set, deleted files and folders that can be undeleted will be displayed.

- `nofiles::Int`: If is set, only the folder (sub)structure will be returned.

- `noshares::Int`: If is set, only user's own folders and files will be displayed.

# Output

Returns folder's `metadata`. The metadata will have `contents` field that is array of metadatas of folder's contents.

# Output Example
```
{
    result: 0,
    metadata: {
        icon: "folder",
        id: "d0",
        modified: "Thu, 19 Sep 2013 07:31:46 +0000",
        path: "/",
        thumb: false,
        created: "Thu, 19 Sep 2013 07:31:46 +0000",
        folderid: 0,
        isshared: false,
        isfolder: true,
        ismine: true,
        name: "/",
        contents: [
            {
                parentfolderid: 0,
                id: "d230807",
                modified: "Wed, 02 Oct 2013 13:23:35 +0000",
                path: "/Simple Folder",
                thumb: false,
                created: "Wed, 02 Oct 2013 13:11:53 +0000",
                folderid: 230807,
                ismine: true,
                isshared: false,
                isfolder: true,
                name: "Simple Folder",
                icon: "folder"
            }, {
                icon: "audio",
                contenttype: "audio/mpeg",
                parentfolderid: 0,
                modified: "Wed, 02 Oct 2013 13:23:19 +0000",
                path: "/Simple Audio.mp3",
                hash: 5380817599554757000,
                thumb: false,
                created: "Wed, 02 Oct 2013 13:23:19 +0000",
                id: "f1723778",
                ismine: true,
                category: 3,
                fileid: 1723778,
                isshared: false,
                isfolder: false,
                name: "Simple Audio.mp3",
                size: 11252576
            }]
    }
}
```
"""),
(:renamefolder, """
	renamefolder(client::PCloudClient; kwargs...)

Renames (and/or moves) a folder identified by `folderid` or `path` to either `topath` (if `topath` is a existing folder to place source folder without new name for the folder it MUST end with slash - `/newpath/`) or `tofolderid`/`toname` (one or both can be provided).

Source: https://docs.pcloud.com/methods/folder/renamefolder.html

# Output

Returns `metadata` of the renamed folder.

# Output Example
```
{
    "result": 0,
    "metadata": {
        "parentfolderid": 0,
        "id": "d230807",
        "modified": "Wed, 02 Oct 2013 13:23:35 +0000",
        "thumb": false,
        "created": "Wed, 02 Oct 2013 13:11:53 +0000",
        "folderid": 230807,
        "ismine": true,
        "isshared": false,
        "isfolder": true,
        "name": "Simple Folder",
        "icon": "folder"
    }
}
```
"""),
(:deletefolder, """
	deletefolder(client::PCloudClient; kwargs...)

Deletes a folder

Expects either `path` string parameter (discouraged) or int `folderid` parameter.

*Note:* Folders must be empty before calling `deletefolder`.

Source: https://docs.pcloud.com/methods/folder/deletefolder.html

# Arguments

- `path::String`: path to the folder (discouraged)

- `folderid::Int`: id of the folder

# Output

Upon success returns `metadata` structure of the deleted folder.

# Output Example
```
{
    "result": 0,
    "id": "111-0",
    "metadata": {
        "icon": "folder",
        "parentfolderid": 0,
        "isfolder": true,
        "isdeleted": true,
        "created": "Wed, 02 Oct 2013 13:11:53 +0000",
        "modified": "Wed, 02 Oct 2013 13:31:49 +0000",
        "isshared": false,
        "name": "Simple Folder",
        "id": "d230807",
        "folderid": 230807,
        "ismine": true,
        "thumb": false
    }
}
```
"""),
(:deletefolderrecursive, """
	deletefolderrecursive(client::PCloudClient; kwargs...)

Deletes a folder

Expects either `path` string parameter (discouraged) or int `folderid` parameter.

*Note:* This function deletes files, directories, and removes sharing. Use with extreme care.

Source: https://docs.pcloud.com/methods/folder/deletefolderrecursive.html

# Arguments

- `path::String`: path to the folder (discouraged)

- `folderid::Int`: id of the folder

# Output

Upon success returns int `deletedfiles` - the number of deleted files and int `deletedfolders` - number of deleted folders.

# Output Example
```
{
    "result": 0,
    "deletedfiles": 30,
    "deletedfolders": 5
}
```
"""),
(:copyfolder, """
	copyfolder(client::PCloudClient; kwargs...)

Copies a folder identified by `folderid` or `path` to either `topath` or `tofolderid`.

Source: https://docs.pcloud.com/methods/folder/copyfolder.html

# Arguments

- `folderid::Int`: id of the source folder

- `path::String`: path of the source folder

- `tofolderid::Int`: id of destination folder

- `topath::String`: destination path

# Optional Arguments

- `noover::Int`: If it is set and files with the same name already exist, no overwriting will be preformed and error 2004 will be returned

- `skipexisting::Int`: If set will skip files that already exist

- `copycontentonly::Int`: If it is set only the content of source folder will be copied otherwise the folder itself is copied

# Output

Returns `metadata` of the created folder.

# Output Example
```
{
    "result": 0,
    "metadata": {
        "parentfolderid": 0,
        "id": "d230807",
        "modified": "Wed, 02 Oct 2013 13:23:35 +0000",
        "thumb": false,
        "created": "Wed, 02 Oct 2013 13:11:53 +0000",
        "folderid": 230807,
        "ismine": true,
        "isshared": false,
        "isfolder": true,
        "name": "Simple Folder",
        "icon": "folder"
    }
}
```
"""),
(:uploadfile, """
	uploadfile(client::PCloudClient; kwargs...)

Upload a file.

String `path` or int `folderid` specify the target directory. If both are omitted the root folder is selected.

Parameter string `progresshash` can be passed. Same should be passed to uploadprogress method.

If `nopartial` is set, partially uploaded files will not be saved (that is when the connection breaks before file is read in full). If `renameifexists` is set, on name conflict, files will not be overwritten but renamed to name like `filename (2).ext`.

Multiple files can be uploaded, using POST with `multipart/form-data` encoding. If passed by POST, the parameters must come before files. All files are accepted, the name of the form field is ignored. Multiple files can come one or more HTML file controls.

Filenames must be passed as `filename` property of each file, that is - the way browsers send the file names.

If a file with the same name already exists in the directory, it is overwritten and old one is saved as revision. Overwriting a file with the same data does nothing except updating the `modification time` of the file.

Source: https://docs.pcloud.com/methods/file/uploadfile.html

# Arguments

- `path::String`: path to the folder(discouraged)

- `folderid::Int`: id of the folder

- `filename::String`: the filename of each uploaded file

# Optional Arguments

- `nopartial::Int`: If is set, partially uploaded files will not be saved

- `progresshash::String`: hash used for observing upload progress

- `renameifexists::Int`: if set, the uploaded file will be renamed, if file with the requested name exists in the folder.

- `mtime::Int`: if set, file modified time is set. Have to be unix time seconds.

- `ctime::Int`: if set, file created time is set. It's required to provide mtime to set ctime. Have to be unix time seconds.

# Output

Returns two arrays - fileids and `metadata`.

# Output Example
```
{
    "result": 0,
    "fileids": [
        1729212
    ],
    "metadata": [
        {
          "ismine": true,
          "id": "f1729212",
          "created": "Wed, 02 Oct 2013 14:29:11 +0000",
          "modified": "Wed, 02 Oct 2013 14:29:11 +0000",
          "hash": 10681749967730527559,
          "isshared": false,
          "isfolder": false,
          "category": 1,
          "parentfolderid": 0,
          "icon": "image",
          "fileid": 1729212,
          "height": 600,
          "width": 900,
          "path": "/Simple image.jpg",
          "name": "Simple image.jpg",
          "contenttype": "image/jpeg",
          "size": 73269,
          "thumb": true
        }
    ]
}

```
"""),
(:uploadprogress, """
	uploadprogress(client::PCloudClient; kwargs...)

Get upload progress of a file.

MUST be sent to the same api server that you are currently uploading to. The parameter string `progresshash` MUST be passed and must contain the same value that was passed in the upload request that is currently in progress.

Source: https://docs.pcloud.com/methods/file/uploadprogress.html

# Arguments

- `progresshash::String`: hash defining the upload, same as sent to uploadfile

# Output

Upon success returns fields:

- `total`: total bytes to be transferred (that is the Content-Length of the upload request)

- `uploaded`: bytes uploaded so far

- `currentfile`: the filename of the file that is currently being uploaded

- `files`: metadata of the already uploaded files (without the current one)

- `finished`: indicates if the upload is finished or not

For finished uploads `currentfile` and `currentfileuploaded` are not present.

Keep in mind that `total` and `uploaded` include the protocol overhead and metadata, `currentfileuploaded` does not.

# Output Example
```
{
    "currentfile": "Simple file",
    "currentfileuploaded": 4199743,
    "result": 0,
    "total": 7768889,
    "filenumber": 1,
    "uploaded": 4199936,
    "finished": false,
    "files": [ ]
}
```
"""),
(:downloadfile, """
	downloadfile(client::PCloudClient; kwargs...)

Download a file/s

Downloads one or more files from links suplied in the `url` parameter (links separated by any amount of whitespace) to the folder identified by either `path` or `folderid` (or to the root folder if both are omitted).

The parameter string `progresshash` can be passed. The same should be passed to uploadprogress method.

When monitoring progress with uploadprogress the following fields will be present:

- `urlcount::Int`: number of URLs requested

- `urlready::Int`: number of URLs already downloaded

- `urlworking::Int`: number of currently downloading URLs

- `finished::Bool`: true if all URLs are downloaded

- `files::array`: of objects

Each record in `files` has:- `url::String`: the url

- `status::String`: One of:waiting the link is waiting for its turn to be downloaded

downloading the link is currently being downloaded

ready the file pointed by url is already downloaded

error error occured while downloading (timeout, 404, server not responding)

- `size::Int`: available only for started downloads only when the server supplied Content-Length - the size of the file

- `downloaded::Int`: available only for started downloads - number of bytes downloaded so far (goes up to size)

- `metadata::metadata`: available only for ready downloads - the metadata of the file in the user's filesystem

The files are saved with the names, that are defined from the urls given. These names could be set, using the parameter `target`, which should contain comma-separeted urlencoded list of the desired names. The n-th name in this sequence is given to the n-th url from `url` parameter.

Note that not all urls could have name given with `target`. If so, leave the name empty ( 'name%20A,,name%20C' ), or stop the list on the last desired name (urls can be more than target names).

Source: https://docs.pcloud.com/methods/file/downloadfile.html

# Arguments

- `url::String`: links separated by any amount of whitespace

# Optional Arguments

- `path::String`: path to folder, in which to download the files

- `folderid::String`: folderid of the folder, in which to download the files

- `target::String`: desired names for the downloaded files

If path or folderid are not present, then root folder is used



# Output

The method returns when all files are downloaded (which might take time). On success `metadata` array with metadata of all downloaded files is returned.

# Output Example
```
{
    "result": 0,
    "metadata": [
        {
            "icon": "image",
            "path": "Simple image.jpg",
            "isshared": false,
            "ismine": true,
            "fileid": 1736716,
            "size": 15604,
            "category": 1,
            "name": "Simple image.jpg",
            "created": "Wed, 02 Oct 2013 15:57:13 +0000",
            "hash": 6306013028049022731,
            "parentfolderid": 0,
            "modified": "Wed, 02 Oct 2013 15:57:28 +0000",
            "thumb": true,
            "isfolder": false,
            "height": 300,
            "width": 222,
            "id": "f1736716",
            "contenttype": "image/jpeg"
        }
    ]
}
```
"""),
(:downloadfileasync, """
	downloadfileasync(client::PCloudClient; kwargs...)

Download a file/s

Downloads one or more files from links suplied in the `url` parameter (links separated by any amount of whitespace) to the folder identified by either `path` or `folderid` (or to the root folder if both are omitted). The response will be recieved when the files are queued for download, not when they are downloaded. The parameter string `progresshash` can be passed. The same should be passed to uploadprogress method. When monitoring progress with uploadprogress the following fields will be present:

- `urlcount::Int`: number of URLs requested

- `urlready::Int`: number of URLs already downloaded

- `urlworking::Int`: number of currently downloading URLs

- `finished::Bool`: true if all URLs are downloaded

- `files::array`: of objects

Each record in `files` has:- `url::String`: the url

- `status::String`: One of:waiting the link is waiting for its turn to be downloadeddownloading the link is currently being downloadedready the file pointed by url is already downloadederror error occured while downloading (timeout, 404, server not responding)

- `size::Int`: available only for started downloads only when the server supplied Content-Length - the size of the file

- `downloaded::Int`: available only for started downloads - number of bytes downloaded so far (goes up to size)

- `metadata::metadata`: available only for ready downloads - the metadata of the file in the user's filesystem

The files are saved with the names, that are defined from the urls given. These names could be set, using the parameter `target`, which should contain comma-separeted urlencoded list of the desired names. The n-th name in this sequence is given to the n-th url from `url` parameter.

Note that not all urls could have name given with `target`. If so, leave the name empty ( 'name%20A,,name%20C' ), or stop the list on the last desired name (urls can be more than target names).

Source: https://docs.pcloud.com/methods/file/downloadfileasync.html

# Arguments

- `url::String`: links separated by any amount of whitespace

# Optional Arguments

- `path::String`: path to folder, in which to download the files

- `folderid::String`: folderid of the folder, in which to download the files

- `target::String`: desired names for the downloaded files

If path or folderid are not present, then root folder is used

# Output

The method returns when all files are downloaded (which might take time). On success `metadata` array with metadata of all downloaded files is returned.

# Output Example
```
{
    "result": 0,
    "metadata": [
        {
            "icon": "image",
            "path": "Simple image.jpg",
            "isshared": false,
            "ismine": true,
            "fileid": 1736716,
            "size": 15604,
            "category": 1,
            "name": "Simple image.jpg",
            "created": "Wed, 02 Oct 2013 15:57:13 +0000",
            "hash": 6306013028049022731,
            "parentfolderid": 0,
            "modified": "Wed, 02 Oct 2013 15:57:28 +0000",
            "thumb": true,
            "isfolder": false,
            "height": 300,
            "width": 222,
            "id": "f1736716",
            "contenttype": "image/jpeg"
        }
    ]
}
```
"""),
(:copyfile, """
	copyfile(client::PCloudClient; kwargs...)

Takes one file and copies it as another file in the user's filesystem.

Expects `fileid` or `path` to identify the source file and `tofolderid`+`toname` or `topath` to identify destination filename.

If `toname` is ommited, original filename is used.

The same is true if the last character of `topath` is '/' (slash), thus identifying only the target folder. The target file will be separate, newly created (with current creation time unless old file is overwritten) independent file.

Any future operations on either the source or destination file will not modify the other one.

This call is useful when you want to create a public link from somebody else's file (shared with you).

Source: https://docs.pcloud.com/methods/file/copyfile.html

# Arguments

- `fileid::Int`: id of the target file

- `path::String`: path to the target file

- `tofolderid::Int`: id of destination folder

- `topath::String`: destination path

Note that not all are required at single method call



# Optional Arguments

- `toname::String`: name of the destination file. If omitted, then the original filename is used

- `noover::Int`: If it is set and file with the specified name already exists, no overwriting will be preformed

- `mtime::Int`: if set, file modified time is set. Have to be unix time seconds.

- `ctime::Int`: if set, file created time is set. It's required to provide mtime to set ctime. Have to be unix time seconds.

# Output

Upon success returns metadata of the destination file ( the copy result ).

# Output Example
```
{
    "result": 0,
    "metadata": {
        "category": 1,
        "width": 900,
        "thumb": true,
        "created": "Wed, 02 Oct 2013 15:05:17 +0000",
        "hash": 10681749967730527559,
        "icon": "image",
        "ismine": true,
        "name": "Simple image.jpg",
        "modified": "Wed, 02 Oct 2013 15:05:17 +0000",
        "isfolder": false,
        "contenttype": "image/jpeg",
        "fileid": 1732283,
        "isshared": false,
        "id": "f1732283",
        "size": 73269,
        "parentfolderid": 28110,
        "height": 600
    }
}
```
"""),
(:checksumfile, """
	checksumfile(client::PCloudClient; kwargs...)

Calculate checksums of a given file

Source: https://docs.pcloud.com/methods/file/checksumfile.html

# Arguments

- `fileid::Int`: id of the checked file

- `path::String`: path to the checked file

Note that fileid or path could be used at once



# Output

Upon success returns `metadata`, `md5` and `sha1` checksums of the file.

# Output Example
```
{
    sha1: "ef2109a0b10ed2033f7ca11c0b62284c5e7fc860",
    md5: "4d200fbf4f7b5ea6eb1877d50e3d6c12",
    metadata: {
        size: 73269,
        parentfolderid: 0,
        width: 900,
        fileid: 1729212,
        contenttype: "image/jpeg",
        hash: 10681749967730528000,
        id: "f1729212",
        isfolder: false,
        thumb: true,
        name: "Simple image.jpg",
        modified: "Wed, 02 Oct 2013 15:05:09 +0000",
        isshared: false,
        height: 600,
        category: 1,
        ismine: true,
        created: "Wed, 02 Oct 2013 14:29:11 +0000",
        icon: "image"
    }
}
```
"""),
(:deletefile, """
	deletefile(client::PCloudClient; kwargs...)

Delete a file identified by `fileid` or `path`.

Source: https://docs.pcloud.com/methods/file/deletefile.html

# Arguments

- `fileid::Int`: ID of the deleted file

- `path::String`: Path to the deleted file

Use fileid or path



# Output

On success returns file's `metadata` with `isdeleted` set.

# Output Example
```
{
    "result": 0,
    "id": "139-0",
    "metadata": {
        "isfolder": false,
        "icon": "image",
        "size": 15604,
        "name": "Simple image.jpg",
        "category": 1,
        "contenttype": "image/jpeg",
        "parentfolderid": 0,
        "isdeleted": true,
        "hash": 6306013028049022731,
        "ismine": true,
        "isshared": false,
        "id": "f1736716",
        "height": 300,
        "width": 222,
        "modified": "Wed, 02 Oct 2013 16:00:40 +0000",
        "thumb": true,
        "created": "Wed, 02 Oct 2013 15:57:13 +0000",
        "fileid": 1736716
    }
}
```
"""),
(:renamefile, """
	renamefile(client::PCloudClient; kwargs...)

Rename a file

Renames (and/or moves) a file identified by `fileid` or `path` to either `topath` (if `topath` is a foldername without new filename it MUST end with slash - /newpath/) or `tofolderid`/`toname` (one or both can be provided).

If the destination file already exists it will be replaced atomically with the source file, in this case the metadata will include `deletedfileid` with the fileid of the old file at the destination, and the source and destination files revisions will be merged together.

Source: https://docs.pcloud.com/methods/file/renamefile.html

# Arguments

- `fileid::Int`: ID of the renamed file

- `path::String`: Path to the renamed file

- `topath::String`: Destination path of renamed file

- `tofolderid::Int`: Id of the folder to which the file is moved

- `toname::String`: Destination filename of the renamed file

Use fileid or path



# Output

On success returns renamed file's `metadata` with `deletedfileid` if merged file.

# Output Example
```
{
    "result": 0,
    "metadata": {
        "id": "f1729212",
        "fileid": 1729212,
        "size": 73269,
        "isfolder": false,
        "hash": 10681749967730527559,
        "isshared": false,
        "thumb": true,
        "height": 600,
        "contenttype": "image/jpeg",
        "icon": "image",
        "created": "Wed, 02 Oct 2013 14:29:11 +0000",
        "width": 900,
        "modified": "Wed, 02 Oct 2013 16:07:40 +0000",
        "ismine": true,
        "name": "My picture.jpg",
        "category": 1,
        "parentfolderid": 0
    }
}
```
"""),
(:stat, """
	stat(client::PCloudClient; kwargs...)

The `stat` API method returns information about the file pointed to by `fileid` or `path`. It's is recomended to use `fileid`.

Source: https://docs.pcloud.com/methods/file/stat.html

# Arguments

- `path::String`: path to the file (discouraged)

- `fileid::Int`: id of the file

# Output

Returns metadata.

# Output Example
```
{
    "result": 0,
    "metadata": {
      "ismine": true,
      "id": "f1729212",
      "created": "Wed, 02 Oct 2013 14:29:11 +0000",
      "modified": "Wed, 02 Oct 2013 14:29:11 +0000",
      "hash": 10681749967730527559,
      "isshared": false,
      "isfolder": false,
      "category": 1,
      "parentfolderid": 0,
      "icon": "image",
      "fileid": 1729212,
      "height": 600,
      "width": 900,
      "path": "/Simple image.jpg",
      "name": "Simple image.jpg",
      "contenttype": "image/jpeg",
      "size": 73269,
      "thumb": true
    }
}

```
"""),
(:sendverificationemail, """
	sendverificationemail(client::PCloudClient; kwargs...)

Sends email to the logged in user with email activation link.

Takes no parameters.

Source: https://docs.pcloud.com/methods/auth/sendverificationemail.html

# Output Example
```
{
    "result": 0
}
```
"""),
(:verifyemail, """
	verifyemail(client::PCloudClient; kwargs...)

Verify an email

Expects parameter `code` that is the activation code sent in validation emails.

In case of valid code, validates user's email address and returns `email` and `userid` of the verified user.

Please keep in mind that the code might be for a user, different than the currently logged one (if any).

Source: https://docs.pcloud.com/methods/auth/verifyemail.html

# Arguments

- `code::String`: activation code sent in validation emails

# Output

- `email::String`: email of the user

- `userid::Int`: id of the user

# Output Example
```
{
    "result": 0,
    "email": "pcloud@pcloud.com",
    "userid": 1234
}
```
"""),
(:changepassword, """
	changepassword(client::PCloudClient; kwargs...)

Change current user's password

Takes `oldpassword` that must contain user's old password and `newpassword` and changes user's password.

New password should be at least 6 characters in length, contain at least 4 different characters, cannot be all consecutive characters (either alphabet or numbers, neither of the following is valid 'abcdef', '123456', '987654') and cannot be all consecutive letters from a standard keyboard (no 'qwerty' or 'poiuyt'). Also the password can not start or end with whitespace.

Source: https://docs.pcloud.com/methods/auth/changepassword.html

# Arguments

- `oldpassword::String`: current password of the user

- `newpassword::String`: the wished password that will overwrite the current

# Output Example
```
{
    "result": 0
}
```
"""),
(:lostpassword, """
	lostpassword(client::PCloudClient; kwargs...)

Change current user's password

Takes as a parameter user's `mail` and sends to this email address insertuctions and link to reset user's password.

Successful reply is sent even if there is no user of the system with `mail` for security reasons.

Source: https://docs.pcloud.com/methods/auth/lostpassword.html

# Arguments

- `mail::String`: e-mail of the user, where instructions are sent

# Output Example
```
{
    "result": 0
}
```
"""),
(:resetpassword, """
	resetpassword(client::PCloudClient; kwargs...)

Reset user's password

Expect as parameters `code` as sent in email in lostpassword

Resets user's password to `newpassword`.

The new password is subject to the same checks as in changepassword.

Source: https://docs.pcloud.com/methods/auth/resetpassword.html

# Arguments

- `code::String`: code sent to the user in lostpassword

- `newpassword::String`: the new password of the user

# Output Example
```
{
    "result": 0
}
```
"""),
(:register, """
	register(client::PCloudClient; kwargs...)

Register a new user account

Parameter `termsaccepted` MUST be set to `yes` if the user accepted terms of service and other agreements.

The new password is subject to the same checks as in changepassword.

Source: https://docs.pcloud.com/methods/auth/register.html

# Arguments

- `mail::String`: user's email address

- `password::String`: the password chosen by the user

# Optional Arguments

- `language::String`: set to one of the supported languages. See supportedlanguages

- `referer::String`: the userid of the refering user

# Output Example
```
{
    "result": 0
}
```
"""),
(:invite, """
	invite(client::PCloudClient; kwargs...)

Get url of a registration page with a referrer code that credits free space to user account upon user registration.

Source: https://docs.pcloud.com/methods/auth/invite.html

# Output

- `url::String`: address of the registration page

- `spacelimitreached::Bool`: is the maximum of free space is reached by the user or not.

# Output Example
```
{
    url: "https://my.pcloud.com/#page=register&invite=invite_code",
    spacelimitreached: false,
    result: 0
}
```
"""),
(:userinvites, """
	userinvites(client::PCloudClient; kwargs...)

Get a list of the invitations of the current user.

Source: https://docs.pcloud.com/methods/auth/userinvites.html

# Output

Returns a list `invites` containing information about the accepted invitations. It has the format:

- `email::String`: the email of the inivted user. For security, part of the mail is hidden.

- `is_pending::Bool`: is the inivitation pending.

New user is added to this list when the invited user is registered and is not pending when the user validates his mail.

# Output Example
```
{
    "invites": [
    {
        "email": "x**@xyz.com",
        "is_pending": 1
    },

    ...

    ] , 
    result: 0
}
```
"""),
(:logout, """
	logout(client::PCloudClient; kwargs...)

Gets a `token` and invalidates it.

Source: https://docs.pcloud.com/methods/auth/logout.html

# Output

Returns bool `auth_deleted` if the `token` invalidation was successful

(token was correct and it was actually invalidated).

# Output Example
```
{
    result: 0,
    auth_deleted: true
}
```
"""),
(:listtokens, """
	listtokens(client::PCloudClient; kwargs...)

Get a list with the currently active tokens associated with the current user.

Source: https://docs.pcloud.com/methods/auth/listtokens.html

# Output

Returns a list `tokens` of objectes full with token information. Every object has the fields:

- `tokenid::Int`: identification number of the token.

- `device::String`: information about the device to which the token was given.

- `created::datetime`: when the token was created.

- `expires_inactive::datetime`: when the token expires, if the owner does not use it.

- `expires::datetime`: when the token expires. This is the latest moment, when the token will be active.

# Output Example
```
{
    "result": 0,
    "tokens": [
        {
            "tokenid": 163409641,
            "device": "User agent info",
            "created": "Mon, 09 Jun 2014 10:24:51 +0000"
            "expires_inactive": "Thu, 10 Jul 2014 10:24:51 +0000",
            "expires": "Tue, 09 Jun 2015 10:24:51 +0000",
        },

        ...

    ]    
}
```
"""),
(:deletetoken, """
	deletetoken(client::PCloudClient; kwargs...)

Delete (invalidate) an authentication token.

The token is identified by `tokenid`. This is recieved from listtokens

Source: https://docs.pcloud.com/methods/auth/deletetoken.html

# Output Example
```
{
    "result": 0
}
```
"""),
(:sendchangemail, """
	sendchangemail(client::PCloudClient; kwargs...)

Sends email to the logged in user with link.

If you send `newmail` and `code`, sends email to `newmail` with link to last step.

Source: https://docs.pcloud.com/methods/auth/sendchangemail.html

# Optional Arguments

- `newmail::String`: newemail of the user

- `code::String`: code sent in email

# Output Example
```
{
    "result": 0
}
```
"""),
(:changemail, """
	changemail(client::PCloudClient; kwargs...)

Change current user's email. Takes `newmail` from `code`.

Source: https://docs.pcloud.com/methods/auth/changemail.html

# Arguments

- `password::String`: current password of the user

- `code::String`: code sent in email

# Output Example
```
{
    "result": 0
}
```
"""),
(:senddeactivatemail, """
	senddeactivatemail(client::PCloudClient; kwargs...)

Sends email to the logged in user with link.

Source: https://docs.pcloud.com/methods/auth/senddeactivatemail.html

# Output Example
```
{
    "result": 0
}
```
"""),
(:deactivateuser, """
	deactivateuser(client::PCloudClient; kwargs...)

Deactivate current user.

Source: https://docs.pcloud.com/methods/auth/deactivateuser.html

# Arguments

- `password::String`: current password of the user

- `code::String`: code sent in email

# Output Example
```
{
    "result": 0
}
```
"""),
(:getfilelink, """
	getfilelink(client::PCloudClient; kwargs...)

Get a download link for file Takes `fileid` (or `path`) as parameter and provides links from which the file can be downloaded.

If the optional parameter `forcedownload` is set, the file will be served by the content server with content type application/octet-stream, which typically forces user agents to save the file.

Alternatively you can provide parameter `contenttype` with the Content-Type you wish the content server to send. If these parameters are not set, the content type will depend on the extension of the file.

Parameter `maxspeed` may be used if you wish to limit the download speed (in bytes per second) for this download.

Finally you can set `skipfilename` so the link generated will not include the name of the file.

Source: https://docs.pcloud.com/methods/streaming/getfilelink.html

# Arguments

- `fileid::Int`: ID of the renamed file

- `path::String`: Path to the renamed file

Use fileid or path

# Optional Arguments

- `forcedownload::Int`: Download with Content-Type = application/octet-stream

- `contenttype::String`: Set Content-Type

- `maxspeed::Int`: limit the download speed

- `skipfilename::Int`: include the name of the file in the generated link

# Output

On success it will return array `hosts` with servers that have the file. The first server is the one we consider `best` for current download.

In `path` there will be a request you should send to server.

You need to construct the URL yourself by concatenating http:// or https:// with one of the `hosts` (first one) and the `path`.

# Output Example
```
{
    result: 0,
    path: "/hash/My%20picture.jpg",
    expires: "Thu, 03 Oct 2013 01:06:49 +0000",
    hosts: [
        "c63.pcloud.com",
        "c1.pcloud.com"
    ]
}
```
"""),
(:getvideolink, """
	getvideolink(client::PCloudClient; kwargs...)

Get a streaming link for video file Takes `fileid` (or `path`) of a video file and provides links (same way getfilelink does with `hosts` and `path`) from which the video can be streamed with lower bitrate (and/or resolution).

The transcoded video will be in a FLV container with x264 video and mp3 audio, by default the video bitrate will be adapted to the connection speed in real time.

By default the content servers will send appropriate content-type for FLV files, this can be overridden with either `forcedownload` or `contenttype` optional parameters.

Optionally `skipfilename` works the same way as in getfilelink.

Transcoding specific optional parameters are:

- `abitrate::Int`: audio bit rate in kilobits, from 16 to 320

- `vbitrate::Int`: video bitrate in kilobits, from 16 to 4000

- `resolution::String`: in pixels, from 64x64 to 1280x960, WIDTHxHEIGHT

- `fixedbitrate::Bool`: if set, turns off adaptive streaming and the stream will be with a constant bitrate.

The video bitrate is only the initial if adaptive straming is used.

The default parameters (that should generally be OK for most cases) are:no change to video resolution (if you know your device resolution it might be a good idea to set `resolution`)initial video bitrate of 1000kbit/sec with adapting to connection speed128kbit audio bitrate Generated links, not the method itself accept the HTTP GET parameter `start`, that if present will skip that much seconds of the video.

Source: https://docs.pcloud.com/methods/streaming/getvideolink.html

# Arguments

- `fileid::Int`: ID of the renamed file

- `path::String`: Path to the renamed file

Use fileid or path

# Optional Arguments

- `forcedownload::Int`: Download with Content-Type = application/octet-stream

- `contenttype::String`: Set Content-Type

- `maxspeed::Int`: limit the download speed

- `skipfilename::Int`: include the name of the file in the generated link

- `abitrate::Int`: audio bit rate in kilobits, from 16 to 320

- `vbitrate::Int`: video bitrate in kilobits, from 16 to 4000

- `resolution::String`: in pixels, from 64x64 to 1280x960, WIDTHxHEIGHT

- `fixedbitrate::Bool`: if set, turns off adaptive streaming and the stream will be with a constant bitrate.

# Output

On success it will return array `hosts` with servers that have the file. The first server is the one we consider `best` for current download.

In `path` there will be a request you should send to server. You need to construct the URL yourself by concatenating http:// or https:// with one of the `hosts` (first one) and the `path`.

# Output Example
```
{
    "result": 0,
    "expires": "Thu, 03 Oct 2013 01:17:11 +0000",
    "path": "/hash/My video.mp4",
    "hosts": [
        "c11.pcloud.com",
        "c20.pcloud.com"
    ]
}
```
"""),
(:getvideolinks, """
	getvideolinks(client::PCloudClient; kwargs...)

Returns `variants` array of different quality/resolution versions of a video, identified by `fileid` (or `path`).

Each variant of the vide will have `path` and `hosts` (as with getfilelink), `width` and `height` of the video, `duration` of the video in seconds (floating point number sent as string), `fps` - frames per second rate of the video, `videobitrate` and `audiobitrate` will specify the bitrate of the video and audio, encoded by respectively `videocodec` and `audiocodec`. For the original video variant `isoriginal` will be true.

By default the content servers will send appropriate content-type for video files, this can be overridden with either `forcedownload` or `contenttype` optional parameters.

Optionally `skipfilename` works the same way as in getfilelink.

Source: https://docs.pcloud.com/methods/streaming/getvideolinks.html

# Arguments

- `fileid::Int`: ID of the renamed file

- `path::String`: Path to the renamed file

Use `fileid` or `path`

# Optional Arguments

- `forcedownload::Int`: Download with Content-Type = application/octet-stream

- `contenttype::String`: Set Content-Type

- `maxspeed::Int`: limit the download speed

- `skipfilename::Bool`: include the name of the file in the generated link

# Output

Explained above.

# Output Example
```
{
  "result": 0,
  "variants": [
    {
      "width": 640,
      "path": "/dFZwfHQZRRZ7Z7Z2b6cC7ZQ5ZZmb0ZK1TMI6SDeOy6pdx78UAVyfUhjd6y/Octane%20Team%202013%20Winter%20Rally%20Training.mp4",
      "fps": "25",
      "isoriginal": false,
      "height": 400,
      "videocodec": "h264",
      "expires": "Wed, 13 Nov 2013 00:28:09 +0000",
      "videobitrate": 501,
      "audiobitrate": 64,
      "audiocodec": "mp3",
      "duration": "245.4",
      "hosts": [
        "c58.pcloud.com",
        "c62.pcloud.com"
      ]
    },
    {
      "width": 1280,
      "path": "/dFZysHQZRRZ7Z7Z2b6cC7ZQ5ZZmb0Z8VoWFa3rb18W6dVJgc1O7hQdWCqV/Octane%20Team%202013%20Winter%20Rally%20Training.mp4",
      "fps": "25",
      "isoriginal": false,
      "height": 720,
      "videocodec": "h264",
      "expires": "Wed, 13 Nov 2013 00:28:09 +0000",
      "videobitrate": 1505,
      "audiobitrate": 128,
      "audiocodec": "mp3",
      "duration": "245.4",
      "hosts": [
        "c3.pcloud.com",
        "c17.pcloud.com"
      ]
    },
    {
      "rotate": 0,
      "path": "/dFZPzZRRZ7Z7Z2b6cC7ZQ5ZZmb0ZoogoFjJUdb01AMSvA1aYdHQmF9Ck/Octane%20Team%202013%20Winter%20Rally%20Training.mp4",
      "fps": "25.00",
      "isoriginal": true,
      "audiosamplerate": 48000,
      "videocodec": "h264",
      "expires": "Wed, 13 Nov 2013 00:28:09 +0000",
      "videobitrate": 5737,
      "audiocodec": "aac",
      "audiobitrate": 189,
      "width": 1280,
      "duration": "245.33",
      "height": 720,
      "hosts": [
        "c3.pcloud.com",
        "c65.pcloud.com"
      ]
    }
  ]
}
```
"""),
(:getaudiolink, """
	getaudiolink(client::PCloudClient; kwargs...)

Get a streaming link for audio file Takes `fileid` (or `path`) of an audio (or video) file and provides links from which audio can be streamed in mp3 format. (Same way getfilelink does with `hosts` and `path`)

Optional parameters are `abitrate`, `forcedownload` and `contenttype`.

The default bitrate is 192kbit.

It can also be used to extract the audio track from a video.

The link itself supports the `start` GET parameter. This method can be used to play FLAC and other new formats on devices that only support mp3 playback.

Source: https://docs.pcloud.com/methods/streaming/getaudiolink.html

# Arguments

- `fileid::Int`: ID of the renamed file

- `path::String`: Path to the renamed file

Use fileid or path

# Optional Arguments

- `forcedownload::Int`: Download with Content-Type = application/octet-stream

- `contenttype::String`: Set Content-Type

- `abitrate::Int`: audio bit rate in kilobits, from 16 to 320

# Output

On success it will return array `hosts` with servers that have the file. The first server is the one we consider `best` for current download.

In `path` there will be a request you should send to server. You need to construct the URL yourself by concatenating http:// or https:// with one of the `hosts` (first one) and the `path`.

# Output Example
```
{
    result: 0,
    expires: "Thu, 03 Oct 2013 01:23:12 +0000",
    path: "/hash/My Audio.mp3",
    hosts: [
        "c53.pcloud.com",
        "c58.pcloud.com"
    ]
}
```
"""),
(:gethlslink, """
	gethlslink(client::PCloudClient; kwargs...)

Get a m3u8 playlist for live streaming for video file

Takes `fileid` (or `path`) of a video file and provides links (in the same way getfilelink does with `hosts` and `path`) from which a m3u8 playlist for HTTP Live Streaming can be downloaded.

Optional parameters are `abitrate`, `vbitrate`, `resolution` and `skipfilename`.

These have the same meaning as in getvideolink.

The defaults are the same as for getvideolink.

Source: https://docs.pcloud.com/methods/streaming/gethlslink.html

# Arguments

- `fileid::Int`: ID of the renamed file

- `path::String`: Path to the renamed file

Use fileid or path

# Optional Arguments

- `abitrate::Int`: audio bit rate in kilobits, from 16 to 320

- `vbitrate::Int`: video bitrate in kilobits, from 16 to 4000

- `resolution::String`: in pixels, from 64x64 to 1280x960, WIDTHxHEIGHT

- `skipfilename::Int`: include the name of the file in the generated link

# Output

On success it will return array `hosts` with servers that have the file. The first server is the one we consider `best` for current download.

In `path` there will be a request you should send to server. You need to construct the URL yourself by concatenating http:// or https:// with one of the `hosts` (first one) and the `path`.

# Output Example
```
{
    expires: "Thu, 03 Oct 2013 01:27:42 +0000",
    result: 0,
    path: "/hash/My video.m3u8",
    hosts: [
        "c11.pcloud.com",
        "c20.pcloud.com"
    ]
}
```
"""),
(:gettextfile, """
	gettextfile(client::PCloudClient; kwargs...)

Download a file in different character encoding Takes `fileid` (or `path`) as parameter and returns contents of the file in different character encoding. The file is streamed as response to this method by the content server.

Optional parameter `fromencoding` specify the original character encoding of the file. If ommited it will be guessed based on the contents of the file.

Optional parameter `toencoding` specify the requested character encoding for the output. The default is `utf-8`.

If the optional parameter `forcedownload` is set, the file will be served by the server with content type application/octet-stream, which typically forces user agents to save the file.

Alternatively you can provide parameter `contenttype` with the Content-Type you wish the server to send. If these parameters are not set, the content type will depend on the extension of the file.

Source: https://docs.pcloud.com/methods/streaming/gettextfile.html

# Arguments

- `fileid::Int`: ID of the renamed file

- `path::String`: Path to the renamed file

Use fileid or path

# Optional Arguments

- `fromencoding::String`: the original character encoding of the file (default: guess)

- `toencoding::String`: requested character encoding of the output (default: utf-8)

- `forcedownload::Int`: Download with Content-Type = application/octet-stream

- `contenttype::String`: Set Content-Type

# Output

On success this method outputs the data by the API server. No links to content servers are provided. Unless you provide invalid encodings in `fromecoding` or `toencoding` you can safely assume that this method will not fail.
"""),
(:getzip, """
	getzip(client::PCloudClient; kwargs...)

Receive a zip file from the user's filesystem.

Expects as parameter a defined tree.

Source: https://docs.pcloud.com/methods/archiving/getzip.html

# Optional Arguments

- `forcedownload::Int`: If it is set, the content-type will be 'application/octet-stream', if not - 'application/zip'.

- `filename::String`: If it is provided, this is sent back as 'Content-Disposition' header, forcing the browser to adopt this filename when downloading the file. Filename is passed unaltered, so it MUST include the .zip extension.

- `timeoffset::String`: desired time offset

# Output

When successful it returns a zip archive over the current API connection with all the files and directories in the requested tree.

If the size of the resulting file is going to be over 4Gb or if it contains more than 65535 entries, the zip64 format is used, otherwise the file is plain zip. This is the fastest way to generate a zip file as the API server will construct the archive on-the-fly for you. Therefore the download will start instantly even with multi-gigabyte files.

Since zip files do not support timezone information for file modification times, by default all datetime values in the resulting zip file will be in UTC. Alternatively `timeoffset` parameter may be provided with the desired time offset in the usual +xxxx or -xxxx format. Also +/-xx:xx and some named timezones (EET, EEST, PST, CST and like) are supported.
"""),
(:getziplink, """
	getziplink(client::PCloudClient; kwargs...)

Receive a zip file link for files in the user's filesystem.

Recognizes the same parameters as getzip.

Expects as parameter a defined tree.

Unlike getzip, returns a download link(s) the same way getfilelink does - returns path, hosts and expire.

*Note : * This call is less efficient than getzip as the zip archive is created on our servers and only then you get a download link. So as fast as our servers are, it may take time to create a large archive.

The parameter `maxspeed` may be used if you wish to limit the download speed (in bytes per second) for this link.

Source: https://docs.pcloud.com/methods/archiving/getziplink.html

# Optional Arguments

- `maxspeed::Int`: limit the download speed (in bytes per second) for this link.

- `forcedownload::Int`: If it is set, the content-type will be 'application/octet-stream', if not - 'application/zip'.

- `filename::String`: If it is provided, this is sent back as 'Content-Disposition' header, forcing the browser to adopt this filename when downloading the file. Filename is passed unaltered, so it MUST include the .zip extension.

- `timeoffset::String`: desired time offset

# Output

On success it will return array `hosts` with servers that have the file.

The first server is the one we consider `best` for current download.

In `path` there will be a request you should send to server.

You need to construct the URL yourself by concatenating http:// or https:// with one of the `hosts` (first one) and the `path`.

# Output Example
```
{
    result: 0,
    path: "/dFZ73Y0ZtdPJZ3lZZhipqC7ZNVZZmb0ZHQp8Ed85S8HL874JvyYgMY8C1tbk/My%20picture.jpg",
    expires: "Thu, 03 Oct 2013 01:06:49 +0000",
    hosts: [
        "c63.pcloud.com",
        "c1.pcloud.com"
    ]
}
```
"""),
(:savezip, """
	savezip(client::PCloudClient; kwargs...)

Create a zip file in the user's filesystem.

Recognizes the same parameters as getzip without `forcedownload` and `filename`.

Expects as parameter a defined tree.

Additionally expects the usual `topath` or `tofolderid`+`toname`.

Source: https://docs.pcloud.com/methods/archiving/savezip.html

# Optional Arguments

- `timeoffset::String`: desired time offset

- `topath::String`: path where to save the zip archive

- `tofolderid::Int`: foldre id of the folder, where to save the zip archive

- `toname::String`: filename of the desired zip archive

- `progresshash::String`: key to retrieve the progress for the zipping process If you want to see the progres, please pass progresshash, different for every method call. To get the progress use savezipprogress

Use `topath` or `tofolderid` and `toname`

# Output

If successful creates the zip archive and returns its `metadata`.

# Output Example
```
{
    result: 0,
    metadata: {
        parentfolderid: 0,
        category: 5,
        hash: 3415575675870461400,
        ismine: true,
        created: "Thu, 03 Oct 2013 09:47:16 +0000",
        modified: "Thu, 03 Oct 2013 09:47:16 +0000",
        contenttype: "application/zip",
        path: "/Simple archive.zip",
        name: "Simple archive.zip",
        size: 17675984,
        isfolder: false,
        isshared: false,
        fileid: 1792497,
        icon: "archive",
        thumb: false,
        id: "f1792497"
    }
}
```
"""),
(:extractarchive, """
	extractarchive(client::PCloudClient; kwargs...)

Extracts archive file from the user's filesystem.

Expects as paramters usual `fileid` or `path` of an archive file and `tofolderid` or `topath` for destination folder.

If the archive is password protected, `password` parameter should be provided, otherwise error number 7009 will be returned. Implementations should expect this error code and if encountered prompt user for password and retry the extraction process.

This method runs the extraction process for around 2 seconds. In case it manages to finish in these 2 seconds, `finished` will be set to true in the response. Otherwise `finished` will be `false` and `progresshash` will be provided. This value can be passed to extractarchiveprogress in order to continue the monitoring of the extraction process. In this case also information about current server is returned the same way as provided by currentserver. Monitoring extraction can only be done by sending requests to the same server as returned in the `hostname`.

Unless `nooutput` is set this method also returns `output` array of lines (with no newlines in the end) that are the output of the extraction program. The number returned in `lines` can be used to instruct extractarchiveprogress not to return the same lines of output again.

Source: https://docs.pcloud.com/methods/archiving/extractarchive.html

# Optional Arguments

- `nooutput::Bool`: if set extraction output is not returned

- `overwrite::String`: specifies what to do if file to extract already exists in the folder, can be one of 'rename' (default), 'overwrite' and 'skip'

- `password::String`: password to use to extract a password protected archive

# Output

Described above.

# Output Example
```
{
  "progresshash": "KooPMKmcEBp",
  "ip": "204.155.151.23",
  "hostname": "api5.pcloud.com",
  "ipv6": "::1",
  "result": 0,
  "lines": 10,
  "ipbin": "204.155.151.45",
  "finished": false,
  "output": [
    "Titov.zip: Zip",
    "  Titov/_ART5055.jpg  (1681557 B)... OK.",
    "  Titov/_ART5059.jpg  (1713601 B)... OK.",
    "  Titov/_ART5063.jpg  (1811854 B)... OK.",
    "  Titov/_ART5069.jpg  (1918700 B)... OK.",
    "  Titov/_ART5071.jpg  (1701381 B)... OK.",
    "  Titov/_ART5074.jpg  (1678731 B)... OK.",
    "  Titov/_ART5076.jpg  (1658403 B)... OK.",
    "  Titov/_ART5079.jpg  (1728540 B)... OK.",
    "  Titov/_ART5094.jpg  (1745843 B)... OK."
  ]
}
```
"""),
(:extractarchiveprogress, """
	extractarchiveprogress(client::PCloudClient; kwargs...)

Returns output and completion status of an archive extraction process.

Expects as paramters `progresshash` as returned by extractarchive and optionally `lines`.

The boolean value `finished` indicates if the process is finished or not. In `output` array lines of output of the extraction program are returned. The number in `lines` can be passed back to this method and will exclude already returned lines of output.

Source: https://docs.pcloud.com/methods/archiving/extractarchiveprogress.html

# Optional Arguments

- `lines::Int`: number of lines of output to skip from the output array

# Output

Described above.

# Output Example
```
{
  "result": 0,
  "lines": 109,
  "finished": true,
  "output": [
    "Titov.zip: Zip",
    "  Titov/_ART5055.jpg  (1681557 B)... OK.",
    "  Titov/_ART5059.jpg  (1713601 B)... OK.",
    "  Titov/_ART5063.jpg  (1811854 B)... OK.",
    "  Titov/_ART5069.jpg  (1918700 B)... OK.",
    "  Titov/_ART5071.jpg  (1701381 B)... OK.",
    "  Titov/_ART5074.jpg  (1678731 B)... OK.",
    "  Titov/_ART5076.jpg  (1658403 B)... OK.",
    "  Titov/_ART5079.jpg  (1728540 B)... OK.",
    "  Titov/_ART5094.jpg  (1745843 B)... OK.",
    "  Titov/_ART5102.jpg  (1716455 B)... OK.",
    "  Titov/_ART5103.jpg  (1616031 B)... OK.",
    "  Titov/_ART5626.jpg  (2174388 B)... OK.",
    "  Titov/_ART5628.jpg  (2061103 B)... OK.",
    "  Titov/_ART5864.jpg  (1490067 B)... OK.",
    "  Titov/_ART5866.jpg  (1503272 B)... OK.",
    "  Titov/_ART5868.jpg  (1748141 B)... OK.",
    "  Titov/_ART5869.jpg  (1839470 B)... OK.",
    "  Titov/_ART5878.jpg  (1264889 B)... OK.",
    "  Titov/_ART6108.jpg  (2190771 B)... OK.",
    "  Titov/_ART6109.jpg  (2019572 B)... OK.",
    "  Titov/_ART6111.jpg  (1939203 B)... OK.",
    "  Titov/_ART6118.jpg  (2279575 B)... OK.",
    "  Titov/_ART6123.jpg  (2204205 B)... OK.",
    "  Titov/_ART6366.jpg  (2135242 B)... OK.",
    "  Titov/_ART6368.jpg  (2287593 B)... OK.",
    "  Titov/_ART6375.jpg  (2191877 B)... OK.",
    "  Titov/_MG_2238.jpg  (1466355 B)... OK.",
    "  Titov/_MG_2244.jpg  (1295216 B)... OK.",
    "  Titov/_MG_2246.jpg  (1460799 B)... OK.",
    "  Titov/_MG_2248.jpg  (1529065 B)... OK.",
    "  Titov/_MG_2253.jpg  (1227511 B)... OK.",
    "  Titov/_MG_2254.jpg  (1480305 B)... OK.",
    "  Titov/_MG_3035.jpg  (1789125 B)... OK.",
    "  Titov/_MG_3164.jpg  (1952735 B)... OK.",
    "  Titov/_MG_3170.jpg  (1063317 B)... OK.",
    "  Titov/_MG_3172.jpg  (2357181 B)... OK.",
    "  Titov/_MG_3173.jpg  (2142821 B)... OK.",
    "  Titov/_MG_3885.jpg  (1311330 B)... OK.",
    "  Titov/_MG_3890.jpg  (1925228 B)... OK.",
    "  Titov/_MG_3892.jpg  (1797677 B)... OK.",
    "  Titov/_MG_3899.jpg  (2225951 B)... OK.",
    "  Titov/_MG_4108.jpg  (1341266 B)... OK.",
    "  Titov/_MG_4409.jpg  (1826640 B)... OK.",
    "  Titov/_MG_4416.jpg  (1312750 B)... OK.",
    "  Titov/_MG_5430.jpg  (1888501 B)... OK.",
    "  Titov/_MG_5458.jpg  (2223461 B)... OK.",
    "  Titov/_MG_5640.jpg  (1850502 B)... OK.",
    "  Titov/_MG_5645.jpg  (1315393 B)... OK.",
    "  Titov/_MG_5646.jpg  (1453218 B)... OK.",
    "  Titov/_MG_5653.jpg  (1448595 B)... OK.",
    "  Titov/_MG_5654.jpg  (1461125 B)... OK.",
    "  Titov/_MG_6130.jpg  (2272260 B)... OK.",
    "  Titov/_MG_6137.jpg  (1042867 B)... OK.",
    "  Titov/_MG_6139.jpg  (1001587 B)... OK.",
    "  Titov/_MG_6147.jpg  (1968840 B)... OK.",
    "  Titov/_MG_6154.jpg  (2471284 B)... OK.",
    "  Titov/_MG_6197.jpg  (1935389 B)... OK.",
    "  Titov/_MG_6200.jpg  (1952539 B)... OK.",
    "  Titov/_MG_6204.jpg  (1547425 B)... OK.",
    "  Titov/_MG_6213.jpg  (1863369 B)... OK.",
    "  Titov/_MG_6227.jpg  (1751445 B)... OK.",
    "  Titov/_MG_6238.jpg  (1530810 B)... OK.",
    "  Titov/Rally_Sliven_2013_FRI_0007.jpg  (3422222 B)... OK.",
    "  Titov/Rally_Sliven_2013_FRI_0010.jpg  (3695719 B)... OK.",
    "  Titov/Rally_Sliven_2013_FRI_0094.jpg  (3521664 B)... OK.",
    "  Titov/Rally_Sliven_2013_FRI_0095.jpg  (2429226 B)... OK.",
    "  Titov/Rally_Sliven_2013_FRI_0096.jpg  (2488633 B)... OK.",
    "  Titov/Rally_Sliven_2013_FRI_0097.jpg  (2655423 B)... OK.",
    "  Titov/Rally_Sliven_2013_FRI_0098.jpg  (2340300 B)... OK.",
    "  Titov/Rally_Sliven_2013_FRI_0099.jpg  (2568207 B)... OK.",
    "  Titov/Rally_Sliven_2013_FRI_0101.jpg  (3147384 B)... OK.",
    "  Titov/Rally_Sliven_2013_FRI_0231.jpg  (1926706 B)... OK.",
    "  Titov/Rally_Sliven_2013_FRI_0238.jpg  (1559040 B)... OK.",
    "  Titov/Rally_Sliven_2013_FRI_0246.jpg  (1869346 B)... OK.",
    "  Titov/Rally_Sliven_2013_FRI_0250.jpg  (1458431 B)... OK.",
    "  Titov/Rally_Sliven_2013_FRI_0251.jpg  (1031734 B)... OK.",
    "  Titov/Rally_Sliven_2013_SAT_0038.jpg  (3613789 B)... OK.",
    "  Titov/Rally_Sliven_2013_SAT_0039.jpg  (3723149 B)... OK.",
    "  Titov/Rally_Sliven_2013_SAT_0040.jpg  (3262341 B)... OK.",
    "  Titov/Rally_Sliven_2013_SAT_0042.jpg  (2788097 B)... OK.",
    "  Titov/Rally_Sliven_2013_SAT_0200.jpg  (3643640 B)... OK.",
    "  Titov/Rally_Sliven_2013_SAT_0201.jpg  (2680875 B)... OK.",
    "  Titov/Rally_Sliven_2013_SAT_0202.jpg  (2544499 B)... OK.",
    "  Titov/Rally_Sliven_2013_SAT_0203.jpg  (2840461 B)... OK.",
    "  Titov/Rally_Sliven_2013_SAT_0204.jpg  (2700571 B)... OK.",
    "  Titov/Rally_Sliven_2013_SAT_0205.jpg  (2631643 B)... OK.",
    "  Titov/Rally_Sliven_2013_SAT_0206.jpg  (2409407 B)... OK.",
    "  Titov/Rally_Sliven_2013_SAT_0345.jpg  (2655096 B)... OK.",
    "  Titov/Rally_Sliven_2013_SAT_0346.jpg  (3268206 B)... OK.",
    "  Titov/Rally_Sliven_2013_SAT_0347.jpg  (2035836 B)... OK.",
    "  Titov/Rally_Sliven_2013_SAT_0348.jpg  (2284103 B)... OK.",
    "  Titov/Rally_Sliven_2013_SAT_0349.jpg  (2071153 B)... OK.",
    "  Titov/Rally_Sliven_2013_SUN_0041.jpg  (2340276 B)... OK.",
    "  Titov/Rally_Sliven_2013_SUN_0042.jpg  (2950695 B)... OK.",
    "  Titov/Rally_Sliven_2013_SUN_0043.jpg  (2526685 B)... OK.",
    "  Titov/Rally_Sliven_2013_SUN_0044.jpg  (2051779 B)... OK.",
    "  Titov/TJP_6400.jpg  (1127206 B)... OK.",
    "  Titov/TJP_6425.jpg  (1239689 B)... OK.",
    "  Titov/TJP_6797.jpg  (1858359 B)... OK.",
    "  Titov/TJP_6799.jpg  (3042033 B)... OK.",
    "  Titov/TJP_7114.jpg  (1375604 B)... OK.",
    "  Titov/TJP_7120.jpg  (1332261 B)... OK.",
    "  Titov/TJP_7126.jpg  (2182860 B)... OK.",
    "  Titov/TJP_7127.jpg  (1519095 B)... OK.",
    "  Titov/TJP_7541.jpg  (2216513 B)... OK.",
    "  Titov/TJP_7867.jpg  (1076556 B)... OK.",
    "  Titov/TJP_7873.jpg  (1079839 B)... OK.",
    "Successfully extracted to current directory."
  ]
}
```
"""),
(:savezipprogress, """
	savezipprogress(client::PCloudClient; kwargs...)

Get the progress in process of zipping file in the user's filesystem.

The process is started with the method savezip. On every zipped file the progress is updated. The process could be marked as ready, once when `files` equals `totalfiles` in the result.

Expects as parameter `progresshash` - key passed to savezip with the intention to observe the progress.

Please, use different `progresshash` for every call of savezip.

Source: https://docs.pcloud.com/methods/archiving/savezipprogress.html

# Optional Arguments

- `progresshash::String`: the key to boserve the zipping process.

# Output

If there exists such zipping process, then the method returns:

- `files::Int`: count of the already zipped files.

- `totalfiles::Int`: total count of files to be zipped.

- `bytes::Int`: size of the already zipped files.

- `totalfiles::Int`: total size of the files to be zipped.

# Output Example
```
{
    "result": 0,
    "files": 34,
    "totalfiles": 129,
    "bytes": 263473,
    "totalbytes": 54750979
}
```
"""),
(:sharefolder, """
	sharefolder(client::PCloudClient; kwargs...)

Shares a folder with another user.

Share may be subject to confirmation from the other user. The folder to be shared is identified by `folderid` or `path`.

Optional share `name` can be provided, if it is not, the folder name is used as sharename. Implementations are advised to give opportunity to the sharing user to select the share `name`, which should be pre-filled with the folder name.

The required parameter `mail` holds the email address of the user with whom you are sharing the folder.

The required parameter `permissions` sets the permissions for the folder.

Zero for read-only or any combination (sum/or) of

- `1`: Create permission

- `2`: Modify permission

- `4`: Delete permission

Optional parameter `message` allows adding a message to pass to the receiving user.

Folder sharing is a complicated operation and the following errors are likely to be returned:- `2014`: the user's address is not verified. Implementations are advised upon user confirmation to call sendverificationemail and to ask the user to check his/her email.

- `2015`: root folder cannot be shared, this check SHOULD also be performed on the client.

- `2016::ismine`: one can only share folders with set to true, implementations SHOULD check this locally too.

- `2017`: user does not accept requests from you or from anybody, implementations can not know if this is going to happen, but are expected to act appropriately on this error.

Source: https://docs.pcloud.com/methods/sharing/sharefolder.html

# Arguments

- `folderid::Int`: folder id of the shared folder

- `path::String`: path to the shared folder

- `mail::String`: mail of the user with whom you are sharing the folder

- `permissions::Int`: bitwise combination of permission flags

Use `path` or `folderid`

# Optional Arguments

- `name::String`: name of the share. Default - the folder name.

- `message::String`: message to pass to the receiving user.

# Output Example
```
{
    result: 0
}
```
"""),
(:listshares, """
	listshares(client::PCloudClient; kwargs...)

List current shares and share requests.

Source: https://docs.pcloud.com/methods/sharing/listshares.html

# Optional Arguments

- `norequests::Int`: If set, share requests will not be returned

- `noshares::Int`: If set, established shares will not be returned

- `noincoming::Int`: If set, hide incoming sub-objects in the result

- `nooutgoing::Int`: If set, hide outgoing sub-objects in the result

# Output

Returns two objects `shares` and `requests` both with sub-objects `incoming` and `outgoing`.

# Output Example
```
{
    result: 0,
    shares: {
        incoming: [ ],
        outgoing: [ ]
    },
    requests: {
        incoming: [ ],
        outgoing: [
            {
                tomail: "pcloud@pcloud.com",
                cancreate: false,
                folderid: 21385,
                sharerequestid: ID,
                canread: true,
                expires: "Thu, 24 Oct 2013 10:41:29 +0000",
                canmodify: false,
                message: "The message",
                candelete: false,
                sharename: "My Share",
                created: "Thu, 03 Oct 2013 10:41:29 +0000"
            }
        ]
    }
}
```
"""),
(:sharerequestinfo, """
	sharerequestinfo(client::PCloudClient; kwargs...)

Get information about a share request from the `code` that was sent to the user's email.

Source: https://docs.pcloud.com/methods/sharing/sharerequestinfo.html

# Arguments

- `code::String`: The code that was sent to the user's email

# Output

Return information about a share.

# Output Example
```
{
    result: 0,
    share: {
        tomail: "pcloud@pcloud.com",
        cancreate: false,
        folderid: 21385,
        sharerequestid: ID,
        canread: true,
        expires: "Thu, 24 Oct 2013 10:41:29 +0000",
        canmodify: false,
        message: "The message",
        candelete: false,
        sharename: "My Share",
        created: "Thu, 03 Oct 2013 10:41:29 +0000"
    }
}
```
"""),
(:cancelsharerequest, """
	cancelsharerequest(client::PCloudClient; kwargs...)

Cancels a share request sent by the current user.

Source: https://docs.pcloud.com/methods/sharing/cancelsharerequest.html

# Arguments

- `sharerequestid::Int`: Identificator of the request

# Output Example
```
{
    result: 0
}
```
"""),
(:acceptshare, """
	acceptshare(client::PCloudClient; kwargs...)

Accept a share request.

The request can be either identified by `sharerequestid` as reported by diff or by a `code` that comes from email.

An optional `name` can be specified for the folder name, otherwise the share name will be used.

Implementations are advised to ask for the local name with `name` pre-filled.

Optionally the target folder to mount the share may be identified by `folderid` or `path`.

If the folder is not specified, the user's default folder for accepting shares will be used, if no such folder exists one with suitable name will be created in the user's root directory.

If the optional parameter `always` is set, the accepting user from now on will auto-accept requests from the sharing user to the default share folder.

Source: https://docs.pcloud.com/methods/sharing/acceptshare.html

# Arguments

- `sharerequestid::Int`: The id of the share request

- `code::String`: The code that was sent to the user's email

Use `sharerequestid` or `code`.

# Optional Arguments

- `name::String`: Specify the folder name. Otherwise, use the share name.

- `folderid::Int`: The id of the folder where to mount the share

- `path::String`: The filepath to the point where to mount the share

- `always::Int`: If set, the accepting user from now on will auto-accept requests from the sharing user to the default share folder.

Use `folderid` or `path`.

# Output Example
```
{
    "result": 0
}
```
"""),
(:declineshare, """
	declineshare(client::PCloudClient; kwargs...)

Decline a share request.

The request can be either identified by `sharerequestid` as reported by diff or by a `code` that comes from email.

If the optional parameter `block` is set, all future share requests from the offering user will be automatically declined.

Source: https://docs.pcloud.com/methods/sharing/declineshare.html

# Arguments

- `sharerequestid::Int`: The id of the share request

- `code::String`: The code that was sent to the user's email

Use `sharerequestid` or `code`.

# Optional Arguments

- `block::Int`: If set, all future share requests from the offering user will be automatically declined.

# Output Example
```
{
    "result": 0
}
```
"""),
(:removeshare, """
	removeshare(client::PCloudClient; kwargs...)

Remove an active share.

This can be both incoming or outgoing share.

Source: https://docs.pcloud.com/methods/sharing/removeshare.html

# Arguments

- `shareid::Int`: The id of the share request, returned by listshares

# Output Example
```
{
    "result": 0
}
```
"""),
(:changeshare, """
	changeshare(client::PCloudClient; kwargs...)

Change permissions of a share.

The permissions are the same as in sharefolder

Only the owner of the share/folder may use this method.

That is - it is only allowed for

*outgoing* shares.

Source: https://docs.pcloud.com/methods/sharing/changeshare.html

# Arguments

- `shareid::Int`: The id of the share request, returned by listshares

- `permissions::String`: The new permissions

# Output Example
```
{
    "result": 0
}
```
"""),
(:getfilepublink, """
	getfilepublink(client::PCloudClient; kwargs...)

Creates and return a public link to a file.

The file is identified by `fileid` or `path`.

Source: https://docs.pcloud.com/methods/public_links/getfilepublink.html

# Arguments

- `fileid::Int`: file id of the file for public link

- `path::String`: path to the file for public link

Use `path` or `fileid`

# Optional Arguments

- `expire::datetime`: Datetime when the link will stop working

- `maxdownloads::Int`: Maximum number of downloads for this file

- `maxtraffic::Int`: Maximum traffic that this link will consume (in bytes, started downloads will not be cut to fit in this limit)

- `shortlink::Int`: If set, a short link will also be generated

# Output

On success returns

- `linkid::Int`: ID that can be used to delete/modify this public link

- `code::String`: link's code that can be used to retrieve the public link contents (with showpublink/getpublinkdownload)

If `shortlink` is set when calling, additonal

- `linkid::Int`: ID that can be used to delete/modify this public link

- `shortcode::String`: short code that can also be passed to showpublink/getpublinkdownload

- `shortlink::String`: a full https link to pc.cd domain with shortcode appended

# Output Example
```
{
    "result": 0,
    "linkid": Link ID,
    "link": "https://my.pcloud.com/#page=publink&code=LinkCode",
    "code": "LinkCode"
}
```
"""),
(:getfolderpublink, """
	getfolderpublink(client::PCloudClient; kwargs...)

Creates and returns a public link to a folder.

The folder is identified by `folderid` or `path`.

Same optional parameters as getfilepublink.

`maxdownloads` in this case limits total number of downloads from this folder (even for the same file).

Source: https://docs.pcloud.com/methods/public_links/getfolderpublink.html

# Arguments

- `folderid::Int`: folder id of the folder for public link

- `path::String`: path to the folder for public link

Use `path` or `folderid`

# Optional Arguments

- `expire::datetime`: Datetime when the link will stop working

- `maxdownloads::Int`: Maximum number of downloads from this folder (even for the same file).

- `maxtraffic::Int`: Maximum traffic that this link will consume (in bytes, started downloads will not be cut to fit in this limit)

- `shortlink::Int`: If set, a short link will also be generated

# Output

On success returns

- `linkid::Int`: ID that can be used to delete/modify this public link

- `code::String`: link's code that can be used to retrieve the public link contents (with showpublink/getpublinkdownload)

If `shortlink` is set when calling, additonal- `linkid::Int`: ID that can be used to delete/modify this public link

- `shortcode::String`: short code that can also be passed to showpublink/getpublinkdownload

- `shortlink::String`: a full https link to pc.cd domain with shortcode appended

# Output Example
```
{
    "result": 0,
    "linkid": Link ID,
    "link": "https://my.pcloud.com/#page=publink&code=LinkCode",
    "code": "LinkCode"
}
```
"""),
(:gettreepublink, """
	gettreepublink(client::PCloudClient; kwargs...)

Creates and returns a public link to a virtual folder that is defined by requested tree.

Tree is identified by the following parameters:

- `fileids`: comma-separated fileids

- `folderids`: comma-separated folderids

- `folderid:`: just one folderid - the contents of the folder will be dumped into the virtual folder instead of the folder itself

Also requires parameter `name` that will be the name of the virtual folder.

Same optional parameters as getfilepublink.

The created link will have similar properties to ones returned by getfolderpublink with one notable exception:

*Note:* Tree public links are snapshots of the requested files and folders at the time of creation and will not follow updates that will happen in the folders later.

Source: https://docs.pcloud.com/methods/public_links/gettreepublink.html

# Arguments

- `folderid::Int`: folder id of the folder for public link

- `path::String`: path to the folder for public link

Use `path` or `folderid`

# Optional Arguments

- `expire::datetime`: Datetime when the link will stop working

- `maxdownloads::Int`: Maximum number of downloads from this folder (even for the same file).

- `maxtraffic::Int`: Maximum traffic that this link will consume (in bytes, started downloads will not be cut to fit in this limit)

- `shortlink::Int`: If set, a short link will also be generated

# Output

On success returns

- `linkid::Int`: ID that can be used to delete/modify this public link

- `code::String`: link's code that can be used to retrieve the public link contents (with showpublink/getpublinkdownload)

If `shortlink` is set when calling, additonal- `linkid::Int`: ID that can be used to delete/modify this public link

- `shortcode::String`: short code that can also be passed to showpublink/getpublinkdownload

- `shortlink::String`: a full https link to pc.cd domain with shortcode appended

# Output Example
```
{
    "result": 0,
    "linkid": Link ID,
    "link": "https://my.pcloud.com/#page=publink&code=LinkCode",
    "code": "LinkCode"
}
```
"""),
(:showpublink, """
	showpublink(client::PCloudClient; kwargs...)

Expects as parameter `code` that can be either 'code' or 'shortcode'.

The `code` could be obtained from:

getfilepublink - link to a single filegetfolderpublink - link to a foldergettreepublink - link to a treegetcollectionpublink - link to a collection

Source: https://docs.pcloud.com/methods/public_links/showpublink.html

# Arguments

- `code::String`: either 'code' or 'shortcode'

# Output

Returns `metadata` of the object the link points to.

If the object is folder, the `contents` field will be present (as in listfolder) with the (recursive) contents of the folder.

The field `isshared` of the returned `metadata` is always `false`, regardless of the real share status of the file/folder.

# Output Example
```
{
    result: 0,
    metadata: {
        isshared: false,
        icon: "folder",
        modified: "Wed, 18 Sep 2013 10:25:57 +0000",
        name: "Simple folder",
        id: "d21721",
        folderid: 21721,
        ismine: true,
        isfolder: true,
        created: "Wed, 18 Sep 2013 10:18:14 +0000",
        thumb: false,
        contents: [
            {
                icon: "audio",
                fileid: 618279,
                parentfolderid: 21721,
                size: 17675824,
                category: 3,
                isfolder: false,
                thumb: true,
                isshared: false,
                ismine: true,
                modified: "Wed, 18 Sep 2013 10:19:05 +0000",
                name: "Simple Audio.mp3",
                artist: "Pcloud",
                trackno: 1,
                genre: "Genre",
                contenttype: "audio/mpeg",
                title: "Simple Audio",
                album: "The album",
                id: "f618279",
                created: "Wed, 18 Sep 2013 10:18:15 +0000",
                hash: 6343095883282229000
            },
            ...
        ]
    }
}
```
"""),
(:getpublinkdownload, """
	getpublinkdownload(client::PCloudClient; kwargs...)

Returns link(s) where the file can be downloaded

Expects as parameter `code` that can be either 'code' or 'shortcode'.

The `code` could be obtained from:

getfilepublink - link to a single file

getfolderpublink - link to a folder

gettreepublink - link to a treegetcollectionpublink - link to a collectionIf the link is to a folder also expects `fileid`.

Optional parameters

*forcedownload*

*contenttype*

*skipfilename*

*maxspeed*work exaclty as explained in getfilelink.

This call is intentionally split from showpublink.

Getting download links for files you do not intend to download is considered

*bad behaviour*.

`getpublinkdownload` is to be called when user intents to actually download the file.

Source: https://docs.pcloud.com/methods/public_links/getpublinkdownload.html

# Arguments

- `code::String`: either 'code' or 'shortcode'

- `fileid::Int`: File id, if the link is to a folder

# Optional Arguments

- `forcedownload::Int`: Download with 'Content-Type' = 'application/octet-stream'

- `contenttype::String`: Set 'Content-Type'

- `maxspeed::Int`: limit the download speed

- `skipfilename::Int`: include the name of the file in the generated link

# Output

Returns link(s) where the file can be downloaded (same as getfilelink`hosts`, `path` and `expire` are returned).

# Output Example
```
{
    result: 0,
    path: "/hash/My%20picture.jpg",
    expires: "Thu, 03 Oct 2013 01:06:49 +0000",
    hosts: [
        "c63.pcloud.com",
        "c1.pcloud.com"
    ]
}
```
"""),
(:copypubfile, """
	copypubfile(client::PCloudClient; kwargs...)

Copies the file from the public link to the current user's filesystem

Expects as parameter `code` that can be either 'code' or 'shortcode'.

The `code` could be obtained from:

getfilepublink - link to a single filegetfolderpublink - link to a foldergettreepublink - link to a treegetcollectionpublink - link to a collectionIf the link is to a folder also expects `fileid`.

As with copyfile you can either specify `topath` or `tofolderid` (with optional `toname`).

Also the optional `noover` works as usual.

Since no actual downloading or traffic happens, using this method does not increment the download nor traffic counters of the public link. Consequently `copypubfile` can be performed even if the public link has run out of downloads or traffic quota.

Implementations are advised to advertise this function when getpublinkdownload returns an error code identifying out of downloads or out of traffic condition. Unauthenticated users, of course, will have to first register/log in in this case.

Source: https://docs.pcloud.com/methods/public_links/copypubfile.html

# Arguments

- `code::String`: either 'code' or 'shortcode'

- `fileid::Int`: File id, if the link is to a folder

- `path::String`: path to the target file

- `tofolderid::Int`: id of destination folder

- `topath::String`: destination path

Note that not all are required at single method call

# Optional Arguments

- `toname::String`: name of the destination file. If omitted, then the original filename is used

- `noover::Int`: If it is set and file with the specified name already exists, no overwriting will be preformed

# Output

When successful, copies the file from the public link to the current user's account and returns the new file's `metadata`.

# Output Example
```
{
    "result": 0,
    "metadata": {
        "category": 1,
        "width": 900,
        "thumb": true,
        "created": "Wed, 02 Oct 2013 15:05:17 +0000",
        "hash": 10681749967730527559,
        "icon": "image",
        "ismine": true,
        "name": "Simple image.jpg",
        "modified": "Wed, 02 Oct 2013 15:05:17 +0000",
        "isfolder": false,
        "contenttype": "image/jpeg",
        "fileid": 1732283,
        "isshared": false,
        "id": "f1732283",
        "size": 73269,
        "parentfolderid": 28110,
        "height": 600
    }
}
```
"""),
(:listpublinks, """
	listpublinks(client::PCloudClient; kwargs...)

Return a list of current user's public links

Takes no parameters

Source: https://docs.pcloud.com/methods/public_links/listpublinks.html

# Output

Returns all user's public links in array `publinks`. For each link the following fields are provided:

- `linkid::Int`: this id can be used to delete or modify the link

- `code::String`: see getfilepublink

- `link::String`: see getfilepublink

- `created::datetime`: date of the link creation

- `modified::datetime`: date of last link modification

- `metadata::contents`: metadata of the object the link points to (directories will not have )

- `downloads::Int`: number of downloads

- `traffic::Int`: traffic consumed so far by this link (bytes)

If the link has a short link:- `shortcode::String`: see getfilepublink

- `shortlink::String`: see getfilepublink

If the link has a short link:- `expires::datetime`: date/time the link will expire (or has expired)

If the link has download limit:- `maxdownloads::Int`: maximum number of downloads for this link

If the link has traffic limit:- `maxtraffic::Int`: maximum traffic for this link

It is up to the implementations to detect and properly display links that have expired or reached the download or traffic limit.

# Output Example
```
{
    result: 0,
    publinks: [
        {
            downloads: 0,
            created: "Thu, 03 Oct 2013 13:06:04 +0000",
            link: "https://my.pcloud.com/#page=publink&code=fileCode",
            modified: "Thu, 03 Oct 2013 13:06:04 +0000",
            code: "fileCode",
            traffic: 2027520,
            linkid: linkid,
            metadata: {
                parentfolderid: 21721,
                created: "Wed, 18 Sep 2013 10:18:15 +0000",
                icon: "audio",
                size: 17675824,
                album: "Simple Album",
                artist: "pCloud",
                trackno: 1,
                isfolder: false,
                contenttype: "audio/mpeg",
                genre: "Audio",
                isshared: false,
                thumb: true,
                ismine: true,
                modified: "Wed, 18 Sep 2013 10:19:05 +0000",
                title: "Simple Audio",
                category: 3,
                hash: 6343095883282229000,
                name: "Simple Audio.mp3",
                fileid: 618279,
                id: "f618279"
            }
        },
        {
            downloads: 0,
            created: "Thu, 03 Oct 2013 13:11:44 +0000",
            link: "https://my.pcloud.com/#page=publink&code=folderCode",
            modified: "Thu, 03 Oct 2013 13:11:44 +0000",
            code: "folderCode",
            traffic: 0,
            linkid: linkid,
            metadata: {
                isfolder: true,
                folderid: 21721,
                isshared: true,
                thumb: false,
                modified: "Wed, 18 Sep 2013 10:25:57 +0000",
                parentfolderid: 0,
                created: "Wed, 18 Sep 2013 10:18:14 +0000",
                ismine: true,
                icon: "folder",
                name: "Simple Folder",
                id: "d21721"
            }
        }
    ]
}
```
"""),
(:listplshort, """
	listplshort(client::PCloudClient; kwargs...)

Return a list of current user's public links listpublinks

There is no `metadata` for each link, instead each link has `isfolder` field and `fileid` or `folderid` field.

Takes no parameters

Source: https://docs.pcloud.com/methods/public_links/listplshort.html

# Output

Returns all user's public links in array `publinks`. For each link the following fields are provided:

- `linkid::Int`: this id can be used to delete or modify the link

- `code::String`: see getfilepublink

- `link::String`: see getfilepublink

- `created::datetime`: date of the link creation

- `modified::datetime`: date of last link modification

- `isfolder::Bool`: true if the link is to folder

- `folderid::Int`: the ID of the folder, if isfolder=true

- `fileid::Int`: the ID of the file, if isfolder=false

- `traffic::Int`: traffic consumed so far by this link (bytes)

If the link has a short link:- `shortcode::String`: see getfilepublink

- `shortlink::String`: see getfilepublink

If the link has a short link:- `expires::datetime`: date/time the link will expire (or has expired)

If the link has download limit:- `maxdownloads::Int`: maximum number of downloads for this link

If the link has traffic limit:- `maxtraffic::Int`: maximum traffic for this link

It is up to the implementations to detect and properly display links that have expired or reached the download or traffic limit.

# Output Example
```
{
    result: 0,
    publinks: [
        {
            isfolder: false,
            traffic: 2027520,
            created: "Thu, 03 Oct 2013 13:06:04 +0000",
            fileid: 618279,
            linkid: 11660,
            downloads: 0,
            modified: "Thu, 03 Oct 2013 13:06:04 +0000",
            code: "fileCode",
            id: "f618279",
            link: "https://my.pcloud.com/#page=publink&code=fileCode"
        },
        {
            isfolder: true,
            traffic: 0,
            created: "Thu, 03 Oct 2013 13:11:44 +0000",
            id: "d21721",
            linkid: 11670,
            downloads: 0,
            folderid: 21721,
            code: "folderCode",
            modified: "Thu, 03 Oct 2013 13:11:44 +0000",
            link: "https://my.pcloud.com/#page=publink&code=folderCode"
        }
    ]
}
```
"""),
(:deletepublink, """
	deletepublink(client::PCloudClient; kwargs...)

Delete a specified public link

Source: https://docs.pcloud.com/methods/public_links/deletepublink.html

# Arguments

- `linkid::Int`: the ID of the link to be deleted

# Output Example
```
{
    result: 0
}
```
"""),
(:changepublink, """
	changepublink(client::PCloudClient; kwargs...)

Modify a specified public link

Source: https://docs.pcloud.com/methods/public_links/changepublink.html

# Arguments

- `linkid::Int`: the ID of the link to be changed

# Optional Arguments

One or more of the following optional parameters MUST be specified:

- `shortlink::Int`: Setting this will create a short link for the link. The response will contain shortcode and shortlink fields.

- `deleteshortlink::Int`: Setting this will delete the short link associated with the link

- `expire::datetime`: Sets a new expiration date for the link

- `deleteexpire::datetime`: If set, deletes link's expiration time (the link will not expire)

- `maxtraffic::Int`: modifies the traffic limit, set to 0 for unlimited

- `maxdownloads::Int`: modifies the downloads limit, set to 0 for unlimited

# Output Example
```
{
    result: 0
}
```
"""),
(:getpubthumb, """
	getpubthumb(client::PCloudClient; kwargs...)

Get a thumbnail of a public file

Same as getthumb, but works on public file identified by `code` (and `fileid` if link is to a folder)

The `code` could be obtained from:

getfilepublink - link to a single filegetfolderpublink - link to a foldergettreepublink - link to a treegetcollectionpublink - link to a collection

Source: https://docs.pcloud.com/methods/public_links/getpubthumb.html

# Arguments

- `code::String`: either 'code' or 'shortcode'

- `fileid::Int`: id of the file for thumb, if the link is to folder

- `size::String`: WIDTHxHEIGHT

# Optional Arguments

- `crop::Int`: If set, then the thumb will be cropped

- `type::String`: If set to png, then the thumb will be in png format
"""),
(:getpubthumblink, """
	getpubthumblink(client::PCloudClient; kwargs...)

Get a link to a thumbnatil of a public file

Same as getthumblink, but works on public file identified by `code` (and `fileid` if link is to a folder)

The `code` could be obtained from:

getfilepublink - link to a single filegetfolderpublink - link to a foldergettreepublink - link to a treegetcollectionpublink - link to a collection

Source: https://docs.pcloud.com/methods/public_links/getpubthumblink.html

# Arguments

- `code::String`: either 'code' or 'shortcode'

- `fileid::Int`: id of the file for thumb, if the link is to folder

- `size::String`: WIDTHxHEIGHT

# Optional Arguments

- `crop::Int`: If set, then the thumb will be cropped

- `type::String`: If set to png, then the thumb will be in png format
"""),
(:getpubthumbslinks, """
	getpubthumbslinks(client::PCloudClient; kwargs...)

Get a link to a thumbnatil of a public file

Same as getthumbslinks, but works on public file identified by `code` (and `fileid` if link is to a folder)

The `code` could be obtained from:

getfilepublink - link to a single filegetfolderpublink - link to a foldergettreepublink - link to a treegetcollectionpublink - link to a collection

Source: https://docs.pcloud.com/methods/public_links/getpubthumbslinks.html

# Arguments

- `code::String`: either 'code' or 'shortcode'

- `fileid::Int`: id of the file for thumb, if the link is to folder

- `size::String`: WIDTHxHEIGHT

# Optional Arguments

- `crop::Int`: If set, then the thumb will be cropped

- `type::String`: If set to png, then the thumb will be in png format
"""),
(:savepubthumb, """
	savepubthumb(client::PCloudClient; kwargs...)

Create a thumbnail of a public link file and save it in the current user's filesystem

Same as savethumb, but works on public file identified by `code` (and `fileid` if link is to a folder)

The `code` could be obtained from:

getfilepublink - link to a single filegetfolderpublink - link to a foldergettreepublink - link to a treegetcollectionpublink - link to a collection

Source: https://docs.pcloud.com/methods/public_links/savepubthumb.html

# Arguments

- `code::String`: either 'code' or 'shortcode'

- `fileid::Int`: id of the file for thumb, if the link is to folder

- `size::String`: WIDTHxHEIGHT

- `topath::String`: filepath where to save the thumb

- `tofolderid::Int`: folder id of the folder where to save the thumb

- `toname::String`: filename to save the thumb

Use `fileid` or `path`

Use `topath` or `tofolderid`+`toname`

# Optional Arguments

- `crop::Int`: If set, then the thumb will be cropped

- `type::String`: If set to png, then the thumb will be in png format

- `noover::Int`: If set, then will rise error on overwriting
"""),
(:getpubzip, """
	getpubzip(client::PCloudClient; kwargs...)

Create a zip archive file of a public link file and download it

Same as getzip, but works on public file identified by `code` (and `fileid` if link is to a folder)

Takes `code` and optional parameters to define a tree and streams a zip file.

The `code` could be obtained from:

getfilepublink - link to a single filegetfolderpublink - link to a foldergettreepublink - link to a treegetcollectionpublink - link to a collection`filename`, `forcedownload` and `timeoffset` optional parameters work the same way as in getzip.

Source: https://docs.pcloud.com/methods/public_links/getpubzip.html

# Arguments

- `code::String`: either 'code' or 'shortcode'

# Optional Arguments

- `forcedownload::Int`: If it is set, the content-type will be 'application/octet-stream', if not - 'application/zip'.

- `filename::String`: If it is provided, this is sent back as 'Content-Disposition' header, forcing the browser to adopt this filename when downloading the file. Filename is passed unaltered, so it MUST include the .zip extension.

- `timeoffset::String`: desired time offset

# Output

When successful it returns a zip archive over the current API connection with all the files and directories in the requested tree.
"""),
(:getpubziplink, """
	getpubziplink(client::PCloudClient; kwargs...)

Create a link to a zip archive file of a public link file

Same as getziplink, but works on public file identified by `code`

`getpubziplink` is slower and less efficient than getpubzip and takes time to generate the zip file as opposed to the former which starts the download right away.

Takes `code` and optional parameters to define a tree and streams a zip file.

The `code` could be obtained from:getfilepublink - link to a single filegetfolderpublink - link to a foldergettreepublink - link to a treegetcollectionpublink - link to a collection

Source: https://docs.pcloud.com/methods/public_links/getpubziplink.html

# Arguments

- `code::String`: either 'code' or 'shortcode'

# Optional Arguments

- `forcedownload::Int`: If it is set, the content-type will be 'application/octet-stream', if not - 'application/zip'.

- `filename::String`: If it is provided, this is sent back as 'Content-Disposition' header, forcing the browser to adopt this filename when downloading the file. Filename is passed unaltered, so it MUST include the .zip extension.

- `timeoffset::String`: desired time offset
"""),
(:savepubzip, """
	savepubzip(client::PCloudClient; kwargs...)

Create a zip archive file of a public link file in the current user filesystem

Same as savezip, but works on public file identified by `code`

Takes `code` and optional parameters to define a tree and streams a zip file.

The `code` could be obtained from:

getfilepublink - link to a single filegetfolderpublink - link to a foldergettreepublink - link to a treegetcollectionpublink - link to a collection

Source: https://docs.pcloud.com/methods/public_links/savepubzip.html

# Arguments

- `code::String`: either 'code' or 'shortcode'

# Optional Arguments

- `timeoffset::String`: desired time offset

- `topath::String`: path where to save the zip archive

- `tofolderid::Int`: foldre id of the folder, where to save the zip archive

- `toname::String`: filename of the desired zip archive

# Output

If successful creates the zip archive and returns its `metadata`.
"""),
(:getpubvideolinks, """
	getpubvideolinks(client::PCloudClient; kwargs...)

Returns `variants` array of different quality/resolution versions of a video in a public link.

Same as getvideolinks, but works on public file identified by `code` (and `fileid` if link is to a folder).

The `code` could be obtained from:

getfilepublink - link to a single filegetfolderpublink - link to a foldergettreepublink - link to a treegetcollectionpublink - link to a collection

Source: https://docs.pcloud.com/methods/public_links/getpubvideolinks.html

# Arguments

- `code::String`: either 'code' or 'shortcode'

# Optional Arguments

- `fileid::Int`: id of the file, if the public link is to a folder

- `forcedownload::Int`: Download with Content-Type = application/octet-stream

- `contenttype::String`: Set Content-Type

- `maxspeed::Int`: limit the download speed

- `skipfilename::Bool`: include the name of the file in the generated link
"""),
(:getpubaudiolink, """
	getpubaudiolink(client::PCloudClient; kwargs...)

Create a link to a audio file of a public link file. The link could be used for streaming.

Same as getaudiolink, but works on public file identified by `code` (and `fileid` if link is to a folder)

The `code` could be obtained from:

getfilepublink - link to a single filegetfolderpublink - link to a foldergettreepublink - link to a treegetcollectionpublink - link to a collection

Source: https://docs.pcloud.com/methods/public_links/getpubaudiolink.html

# Arguments

- `code::String`: either 'code' or 'shortcode'

# Optional Arguments

- `fileid::Int`: id of the file, if the public link is to a folder

- `forcedownload::Int`: Download with Content-Type = application/octet-stream

- `contenttype::String`: Set Content-Type

- `abitrate::Int`: audio bit rate in kilobits, from 16 to 320
"""),
(:getpubtextfile, """
	getpubtextfile(client::PCloudClient; kwargs...)

Download a file in different character encoding The file is streamed as response to this method by the content server.

Same as gettextfile, but works on public file identified by `code` (and `fileid` if link is to a folder)

The `code` could be obtained from:

getfilepublink - link to a single filegetfolderpublink - link to a foldergettreepublink - link to a treegetcollectionpublink - link to a collection

Source: https://docs.pcloud.com/methods/public_links/getpubtextfile.html

# Arguments

- `code::String`: either 'code' or 'shortcode'

# Optional Arguments

- `fileid::Int`: id of the file, if the public link is to a folder

- `fromencoding::String`: the original character encoding of the file (default: guess)

- `toencoding::String`: requested character encoding of the output (default: utf-8)

- `forcedownload::Int`: Download with Content-Type = application/octet-stream

- `contenttype::String`: Set Content-Type
"""),
(:getcollectionpublink, """
	getcollectionpublink(client::PCloudClient; kwargs...)

Generates a public link to a collection, owned by the current user.

This method has the same optional parameters as getfilepublink.

*Note:* Public links pointing to a collection have the advantage that are real time image of the collection, while tree links are snapshots.

Source: https://docs.pcloud.com/methods/public_links/getcollectionpublink.html

# Arguments

- `collectionid::Int`: the id of the collection

# Optional Arguments

- `expire::datetime`: Datetime when the link will stop working

- `maxdownloads::Int`: Maximum number of downloads from this folder (even for the same file).

- `maxtraffic::Int`: Maximum traffic that this link will consume (in bytes, started downloads will not be cut to fit in this limit)

- `shortlink::Int`: If set, a short link will also be generated

# Output Example
```
{
    "result": 0,
    "link": "https://my.pcloud.com/#page=publink&code=PUBLIC_LINK_CODE",
    "code": "PUBLIC_LINK_CODE",
    "linkid": LINK_ID
}
```
"""),
(:getthumblink, """
	getthumblink(client::PCloudClient; kwargs...)

Get a link to a thumbnail of a file

Takes `fileid` (or `path`) as parameter and provides links from which a thumbnail of the file can be downloaded.

Thumbnails can be created only from files whose metadata has `thumb` value set to `true`.

The parameter `size` MUST be provided, in the format WIDTHxHEIGHT.

The width MUST be between 16 and 2048, and divisible by either 4 or 5.

The height MUST be between 16 and 1024, and divisible by either 4 or 5.

By default the thumb will have the same aspect ratio as the original image, so the resulting thumbnail width or height (but not both) might be less than requested.

If you want thumbnail exactly the size specified, you can set `crop` parameter. With `crop`, thumbnails will still have the right aspect ratio, but if needed some rows or cols (but not both) will be cropped from both sides. So if you have 1024x768 image and are trying to create 128x128 thumbnail, first the image will be converted to 768x768 by cutting 128 columns from both sides and then resized to 128x128. To create a rectangular thumb from 4:3 image exactly 1/8 is cropped from each side. By default the thumbnail is in jpeg format.

If the `type` parameter is set to png, a png image will be produced.

Thumbs are created on first request and cached for unspecified amount of time (or until file) changes.

Clients should attempt to cache thumbs if space permits.

It is also advisable to monitor the original file's `hash` to see if it has changed. If yes, a new thumbnail MUST be requested.

Source: https://docs.pcloud.com/methods/thumbnails/getthumblink.html

# Arguments

- `fileid::Int`: id of the file for thumb

- `path::String`: filepath to the file for thumb

- `size::String`: WIDTHxHEIGHT

Use `fileid` or `path`

# Optional Arguments

- `crop::Int`: If set, then the thumb will be cropped

- `type::String`: If set to png, then the thumb will be in png format

# Output

On success the same data as with `getfilelink` is returned.

Additionally the real image produced `size` is returned

It will match reqested size if `crop` is specified or may differ otherwise.

# Output Example
```
{
    result: 0,
    size: "32x32",
    path: "/hash/My%20thumb.jpg",
    expires: "Thu, 03 Oct 2013 01:06:49 +0000",
    hosts: [
        "c63.pcloud.com",
        "c1.pcloud.com"
    ]
}
```
"""),
(:getthumbslinks, """
	getthumbslinks(client::PCloudClient; kwargs...)

Get a link to thumbnails of a list of files

Takes in `fileids` parameter coma-separated list of fileids and returns thumbs for all the files.

`size`, `type` and `crop` work like in getthumblink and are all the same for all files.

If you need to generate multiple thumbnails `getthumbslinks` is preferable than multiple calls to `getthumblink` (even if pipelined)

`getthumbslinks` connects to multiple storage serves simultaneously to generate thumbs and in most cases it is just slightly slower than a single call to `getthumblink` even if multiple thumbnails are requested.

Source: https://docs.pcloud.com/methods/thumbnails/getthumbslinks.html

# Arguments

- `fileids::String`: coma-separated list of fileids

- `size::String`: WIDTHxHEIGHT

# Optional Arguments

- `crop::Int`: If set, then the thumb will be cropped

- `type::String`: If set to png, then the thumb will be in png format

# Output

The method returns an array `thumbs` with objects. Each object has `result` and `fileid` set.

If result is non-zero, `error` is also provided.

Otherwise `path`, `hosts`, `expires` and `size` are provided as in getfilelink.

# Output Example
```
{
    "result": 0,
    "thumbs": [
        {
            "expires": "Thu, 03 Oct 2013 23:04:48 +0000",
            "size": "32x32",
            "result": 0,
            "path": "/dFZVBFVZIpqkZIJZZdzeqC7Z3VZZmb0ZedrcUj5eXifiCM1JvlWCtfOG0zsy/th-FileID-32x32.png",
            "fileid": FileID,
            "hosts": [
                "c14.pcloud.com"
            ]
        },
        ...
    ]
}
```
"""),
(:getthumb, """
	getthumb(client::PCloudClient; kwargs...)

Get a thumbnail of a file

Takes the same parameters as getthumblink, but returns the thumbnail over the current API connection.

Getting thumbnails from API servers is generally NOT faster than getting them from storage servers.

It makes sense only if you are reusing the (possibly expensive to open SSL) API connection.

Source: https://docs.pcloud.com/methods/thumbnails/getthumb.html

# Arguments

- `fileid::Int`: id of the file for thumb

- `path::String`: filepath to the file for thumb

- `size::String`: WIDTHxHEIGHT

Use `fileid` or `path`

# Optional Arguments

- `crop::Int`: If set, then the thumb will be cropped

- `type::String`: If set to png, then the thumb will be in png format
"""),
(:savethumb, """
	savethumb(client::PCloudClient; kwargs...)

Create a thumbnail of a file and save it in the current user's filesystem

takes the same parameters as getthumblink in addition to `topath` or `tofolderid`+`toname` and save the generated thumbnail as a file.

As usual by default this call overwrites existing files (saving the old one as revision) unless the `noover` parameter is set. In that case 'File or folder alredy exists.' error will be generated.

If `toname` is not provided, but `tofolderid` is, the file's original name is used for the thumbnail.

Similarly if `topath` ends with a slash ('/'), the original filename is appended.

Source: https://docs.pcloud.com/methods/thumbnails/savethumb.html

# Arguments

- `fileid::Int`: id of the file for thumb

- `path::String`: filepath to the file for thumb

- `size::String`: WIDTHxHEIGHT

- `topath::String`: filepath where to save the thumb

- `tofolderid::Int`: folder id of the folder where to save the thumb

- `toname::String`: filename to save the thumb

Use `fileid` or `path`

Use `topath` or `tofolderid`+`toname`

# Optional Arguments

- `crop::Int`: If set, then the thumb will be cropped

- `type::String`: If set to png, then the thumb will be in png format

- `noover::Int`: If set, then will rise error on overwriting

# Output

On success returns `metadata`, `width` and `height`.

# Output Example
```
{
    result: 0,
    height: 32,
    width: 32,
    metadata: {
        path: "/my%20thumb.jpg",
        thumb: true,
        modified: "Thu, 03 Oct 2013 15:30:43 +0000",
        parentfolderid: 0,
        created: "Thu, 03 Oct 2013 15:30:43 +0000",
        ismine: true,
        category: 1,
        hash: 1154152318038973000,
        isshared: false,
        contenttype: "image/jpeg",
        fileid: 1818093,
        size: 650,
        id: "f1818093",
        icon: "image",
        name: "my thumb.jpg",
        isfolder: false
    }
}
```
"""),
(:createuploadlink, """
	createuploadlink(client::PCloudClient; kwargs...)

Creates upload link.

Expects `folderid`/`path` of the folder where the uploaded files will be saved. The folder must be owned by the user. Share may be subject to confirmation from the other user.

The folder to be shared is identified by `folderid` or `path`.

Also SHOULD have a `comment` parameter that contains any comments/instructions the user is willing to provide to uploading users. Comments are the only information that uploading users will see (they will not know username of the owner nor the name of the folder they are uploading into) so implementations SHOULD instruct users to fill in at least some description of what is expected from the uploaders (e.g. Hey, that's Mike. Please upload any pictures you took at my wedding here.).

Optional parameter `expire` may indicate a date/time at which the link will stop working.

Also optionally `maxspace` and `maxfiles` may limit maximum total size (in bytes) and total number of files that can be uploaded.

Source: https://docs.pcloud.com/methods/upload_links/createuploadlink.html

# Arguments

- `folderid::Int`: folder id of the folder, where the uploaded files will be saved

- `path::String`: path to the shared folder, where the uploaded files will be saved

- `comment::String`: comment the user is willing to provide to uploading users

Use `path` or `folderid`

# Optional Arguments

- `expire::datetime`: date/time at which the link will stop working.

- `maxspace::Int`: limit maximum total size (in bytes)

- `maxfiles::Int`: otal number of files that can be uploaded

# Output

On success returns

- `uploadlinkid::Int`: can be used to modify/delete this link

- `link::String`: full link to a page where files can be uploaded

- `mail::String`: an email address that also can be used to upload files to this link

- `code::String`: link's code that can be used to upload files.

{

"result": 0,

"code": "linkCode",

"mail": "somewhere@u.pcloud.com",

"uploadlinkid": linkID,

"link": "https://my.pcloud.com/#page=puplink&code=linkCode"

}
"""),
(:listuploadlinks, """
	listuploadlinks(client::PCloudClient; kwargs...)

Lists all upload links in uploadlinks.

Source: https://docs.pcloud.com/methods/upload_links/listuploadlinks.html

# Output

For each link lists:

- `uploadlinkid::Int`: can be used to modify/delete this link

- `link::String`: full link to a page where files can be uploaded

- `mail::String`: an email address that also can be used to upload files to this link

- `code::String`: link's code that can be used to upload files

- `comment::String`: comment of the upload link

- `files::Int`: number of uploaded files

- `space::Int`: total space occupied by uploaded files in bytes

- `metadata::metadata`: target folder's metadata

- `created::datetime`: when the link was created

- `last modified::datetime`: when the link was last modified

Optionally if specified at creation time:- `expire::datetime`: date/time at which the link will stop working.

- `maxspace::Int`: limit maximum total size (in bytes)

- `maxfiles::Int`: otal number of files that can be uploaded

# Output Example
```
{
    "result": 0,
    "uploadlinks": [
        {
            "space": 23640,
            "files": 23,
            "mail": "somewhere@u.pcloud.com",
            "maxspace": 524288000,
            "created": "Fri, 04 Oct 2013 16:26:41 +0000",
            "code": "linkCode",
            "maxfiles": 100,
            "comment": "Upload link comment",
            "link": "https://my.pcloud.com/#page=puplink&code=linkCode",
            "uploadlinkid": UploadLinkID,
            "modified": "Fri, 04 Oct 2013 16:26:41 +0000",
            "metadata": {
                "isfolder": true,
                "folderid": folderid,
                "thumb": false,
                "icon": "folder",
                "created": "Wed, 18 Sep 2013 10:18:14 +0000",
                "ismine": true,
                "isshared": true,
                "parentfolderid": 0,
                "name": "Simple Upload Place",
                "modified": "Wed, 18 Sep 2013 10:25:57 +0000",
                "id": "id"
            }
        }
    ]
}
```
"""),
(:deleteuploadlink, """
	deleteuploadlink(client::PCloudClient; kwargs...)

Deletes upload link identified by `uploadlinkid`.

Source: https://docs.pcloud.com/methods/upload_links/deleteuploadlink.html

# Arguments

- `uploadlinkid::Int`: id of the deleted upload link

# Output Example
```
{
    "result": 0
}
```
"""),
(:changeuploadlink, """
	changeuploadlink(client::PCloudClient; kwargs...)

Modify upload link identified by `uploadlinkid`.

Options that, could be changed include:

Expiration date

Space of the upload link

Files of the upload link

Source: https://docs.pcloud.com/methods/upload_links/changeuploadlink.html

# Arguments

- `uploadlinkid::Int`: id of the upload link

# Optional Arguments

- `expire::datetime`: set expiration date of the link

- `deleteexpire::Int`: if set, link's expiration date is removed

- `maxspace::Int`: alter the maximum available space (in bytes) of the link

- `maxfiles::Int`: alter the maximum available files of the link

Set `maxspace` or `maxfiles` to `0` to remove the given limit.
"""),
(:showuploadlink, """
	showuploadlink(client::PCloudClient; kwargs...)

Expects upload link `code` and returns back the link's `comment` and `mail`.

If the link is deleted or expired, returns proper 7xxx error, which should be expected by the implementations.

Modify upload link identified by `uploadlinkid`. Options that, could be changed include:

Expiration date

Space of the upload link

Files of the upload link

Source: https://docs.pcloud.com/methods/upload_links/showuploadlink.html

# Arguments

- `uploadlinkid::Int`: id of the upload link

# Optional Arguments

- `expire::datetime`: set expiration date of the link

- `deleteexpire::Int`: if set, link's expiration date is removed

- `maxspace::Int`: alter the maximum available space (in bytes) of the link

- `maxfiles::Int`: alter the maximum available files of the link

Set `maxspace` or `maxfiles` to `0` to remove the given limit.

# Output Example
```
{
    "result": 0
}
```
"""),
(:uploadtolink, """
	uploadtolink(client::PCloudClient; kwargs...)

Upload file(s) to a upload link. Expects `code`.

Most things that apply to uploadfile also apply here, especially `progresshash` can be used in the same manner to monitor upload progress with uploadlinkprogress.

There is a slight difference that `renameifexists` is omitted and the uploaded file is always renamed when a file with the requested name exists in the upload link.

Source: https://docs.pcloud.com/methods/upload_links/uploadtolink.html

# Arguments

- `code::String`: code of the link

# Optional Arguments

- `nopartial::Int`: If is set, partially uploaded files will not be saved

- `progresshash::String`: hash used for observing upload progress

# Output Example
```
{
    result: 0
}
```
"""),
(:uploadlinkprogress, """
	uploadlinkprogress(client::PCloudClient; kwargs...)

Monitor the progress of uploaded files.

Source: https://docs.pcloud.com/methods/upload_links/uploadlinkprogress.html

# Arguments

- `code::String`: code of the upload link

- `progresshash::String`: hash for monitoring passed to uploadtolink

# Output

Returns same data as uploadprogress but without `files`.
"""),
(:copytolink, """
	copytolink(client::PCloudClient; kwargs...)

Copy a file from the current user's filesystem to a upload link.

Source: https://docs.pcloud.com/methods/upload_links/copytolink.html

# Arguments

- `code::String`: code of the upload link

- `fileid::Int`: id of the copied file

- `path::String`: path the copied file

Use "fileid" or "path"



# Optional Arguments

toname "string" the name to save the copied file. If it is not provided, then the name of the file is used.
"""),
(:listrevisions, """
	listrevisions(client::PCloudClient; kwargs...)

Lists revisions for a given `fileid` / `path`

Source: https://docs.pcloud.com/methods/revisions/listrevisions.html

# Arguments

- `fileid::Int`: id of the revisioned file

- `path::String`: path the revisioned file

Use `fileid` or `path`

# Output

Lists the revisions as array, each element with the following fields:

- `revisionid::Int`: id of the revision

- `size::Int`: filesize of the given revision of the file

- `hash::String`: file contents hash (same as in metadata)

- `created::datetime`: date/time at which the revision was created

Also returns the metadata of the file.
"""),
(:revertrevision, """
	revertrevision(client::PCloudClient; kwargs...)

Takes `fileid`/`path` and `revisionid` as parameters and reverts the file to a given revision.

Current file contents are saved as new revision.

Source: https://docs.pcloud.com/methods/revisions/revertrevision.html

# Arguments

- `fileid::Int`: id of the reverted file

- `path::String`: path the reverted file

- `revisionid::Int`: id of the revistion, to which the file is reverted

Use `fileid` or `path`

# Output

On success returns new metadata of the file.
"""),
(:file_open, """
	file_open(client::PCloudClient; kwargs...)

Opens a file descriptor.

Source: https://docs.pcloud.com/methods/fileops/file_open.html

# Arguments

- `flags::Int`: which can be a combination of the file_open flags.

# Optional Arguments

- `path::String`: path to the file, for which the file descirptior is created.

- `fileid::Int`: id of the folder, for which the file descirptior is created.

- `folderid::Int`: id of the folder, in which new file is created and file descirptior is returned.

- `name::String`: name of the file, in which new file is created and file descirptior is returned.

The use of these parameters, depends on the flags are given. Please, see the details below.

# Output

On success returns `fd` file descriptor which can be used in successive operations. Also returns the `fileid` of the file (useful when creating file).

# Output Example
```
{
    result: 0,
    fd: 1,
    fileid: 3489
}
```
"""),
(:file_write, """
	file_write(client::PCloudClient; kwargs...)

Writes as much data as you send to the file descriptor `fd` to the current file offset and adjusts the offset.

You can see how to send data here.

Source: https://docs.pcloud.com/methods/fileops/file_write.html

# Arguments

- `fd::Int`: the file descriptor, to which data is written

# Output

Returns `bytes` (number of bytes) written.

# Output Example
```
{
    result: 0,
    bytes: 124
}
```
"""),
(:file_pwrite, """
	file_pwrite(client::PCloudClient; kwargs...)

Writes as much data as you send to the file descriptor `fd`. Data is written at the `offset` that is provided as parameter.

file_pwrite ignores the O_APPEND flag. The file's offset is not changed.

You can see how to send data here.

Source: https://docs.pcloud.com/methods/fileops/file_pwrite.html

# Arguments

- `fd::Int`: the file descriptor, to which data is written

- `offset::Int`: the offset in bytes, from where the data is written

# Output

Returns `bytes` (number of bytes) written.

# Output Example
```
{
    result: 0,
    bytes: 124
}
```
"""),
(:file_read, """
	file_read(client::PCloudClient; kwargs...)

Tries to read at most `count` bytes at the current offset of the file.

If currentofset+count<=filesize this method will satisfy the request and read `count` bytes, otherwise it will return just the bytes available (this is the only way to discover the EOF condition).

You can see how to read data here.

Source: https://docs.pcloud.com/methods/fileops/file_read.html

# Arguments

- `fd::Int`: the file descriptor, from which data is read

- `count::Int`: count in bytes, which to be read from the descriptor

# Output

Returns the data.
"""),
(:file_pread, """
	file_pread(client::PCloudClient; kwargs...)

Tries to read at most `count` bytes at the given `offset` of the file.

You can see how to read data here.

Source: https://docs.pcloud.com/methods/fileops/file_pread.html

# Arguments

- `fd::Int`: the file descriptor, from which data is read

- `count::Int`: count in bytes, which to be read from the descriptor

- `offset::Int`: in bytes, from where to start reading in the file

# Output

Returns the data.
"""),
(:file_pread_ifmod, """
	file_pread_ifmod(client::PCloudClient; kwargs...)

Same as file_pread, but additionally expects `sha1` or `md5` parameter (hex).

If the checksum of the data to be read matches the `sha1` or `md5` checksum, it returns error code 6000 Not modified.

This call is useful if the application has the data cached and wants to verify if it still current.

You can see how to read data here.

Source: https://docs.pcloud.com/methods/fileops/file_pread_ifmod.html

# Arguments

- `fd::Int`: the file descriptor, from which data is read

- `count::Int`: count in bytes, which to be read from the descriptor

- `offset::Int`: in bytes, from where to start reading in the file

- `sha1::String`: the SHA-1 checksum of the part of the file from the offset, to be checked

- `md5::String`: the MD5 checksum of the part of the file from the offset, to be checked

Use `sha1` or `md5`, but not both.

# Output

Returns the data.
"""),
(:file_checksum, """
	file_checksum(client::PCloudClient; kwargs...)

Calculates checksums of `count` bytes at `offset` from the file descripor `fd`.

DO NOT use this function to calculate checksums of an entire, unmodified file, use checksumfile instead.

Source: https://docs.pcloud.com/methods/fileops/file_checksum.html

# Arguments

- `fd::Int`: the file descriptor, for which checksums are calculated

- `count::Int`: count in bytes, for which checksums are calculated

- `offset::Int`: from where in bytes the checksum calculation starts

# Output

Returns `sha1`, `md5` and `size`.

`size` will be equal to `count` unless bytes past current filesize are requested to be checksummed.

# Output Example
```
{
    result: 0,
    sha1: "SHA-1 checksum",
    md5: "MD5 checksum",
    size: "count of bytes, for which the checksums are calculated"
}
```
"""),
(:file_size, """
	file_size(client::PCloudClient; kwargs...)

Gives `size` (in bytes) and current `offset` for a given `fd`.

Source: https://docs.pcloud.com/methods/fileops/file_size.html

# Arguments

- `fd::Int`: the file descriptor, for which the size and offset are given

# Output Example
```
{
    result: 0,
    size: "Size of the ",
    offset: "Current offset"
}
```
"""),
(:file_truncate, """
	file_truncate(client::PCloudClient; kwargs...)

Sets file size to `length` bytes.

If `length` is less than the file size, then the extra data is cut from the file, else the the file contents are extended with zeroes as needed.

The current offset is not modified.

Source: https://docs.pcloud.com/methods/fileops/file_truncate.html

# Arguments

- `fd::Int`: the file descriptor, for which the size and offset are given

- `length::Int`: to how much bytes to set the file size

# Output Example
```
{
    result: 0
}
```
"""),
(:file_seek, """
	file_seek(client::PCloudClient; kwargs...)

Sets the current offset of the file descriptor to `offset` bytes.

This methods works in the following modes, depending on the `whence` parameter:

- `0`: moves after beginning of the file

- `1`: after current position

- `2`: after end of the file

Source: https://docs.pcloud.com/methods/fileops/file_seek.html

# Arguments

- `fd::Int`: the file descriptor, for which the current offset is changed

- `offset::Int`: the offset in bytes, to which to move the current offset

# Optional Arguments

- `whence::Int`: mode, in which the offset seek works. Default value is 0

# Output

Returns the new `offset`.

# Output Example
```
{
    result: 0,
    offset: 1024
}
```
"""),
(:file_close, """
	file_close(client::PCloudClient; kwargs...)

Closes the file descriptor.

Source: https://docs.pcloud.com/methods/fileops/file_close.html

# Arguments

- `fd::Int`: the file descriptor, which is closed

# Output Example
```
{
    result: 0
}
```
"""),
(:file_lock, """
	file_lock(client::PCloudClient; kwargs...)

Locks or unlocks a file descriptor `fd`.

This method works, depending on the `type` paramater:

- `0`: release a lock

- `1`: get a shared lock

- `2`: get an exclusive lock

If the `offset` parameter is provided, only bytes starting from this offset are locked.

If the `length` parameter is provided, only `length` bytes starting from `offset` are locked. Length of 0 means lock until the end of file (no matter how big it grows).

The offset of this method could be interpreted depending on `whence` parameter:- `0`: offset is from the start of the file

- `1`: offset is from current offset

- `2`: offset is from the end of the file

If the parameter `get` is set, then instead of acquiring the lock only a test is performed if the file region can be locked.

By default locks are blocking, that is the call will block until the lock is granted (except when `get` is set or request is for unlocking). If you do not wish the lock to block, set the `noblock` parameter.

Locks are advisory locks, that is, they are not enforced on readers/writers that are not trying to take a lock.

You may hold just one lock on a file region. If shared lock is to be converted to an exclusive lock, the conversion is not atomic - the shared lock MIGHT be released first, before acquiring the exclusive lock. That happens only if the request for the exclusive lock can not be satisfied at the moment. This is done to prevent two processes from deadlocking by first holding a shared lock on a file and later trying to convert it to an exclusive lock. Processes still can deadlock by acquiring TWO locks simultaneously (each) on different files/regions in different order.

The API servers do not perform any kind of deadlock detection.

Source: https://docs.pcloud.com/methods/fileops/file_lock.html

# Arguments

- `fd::Int`: the file descriptor, which is locked or unlocked

- `type::Int`: what operation is performed to the file lock

# Optional Arguments

- `offset::Int`: lock only bytes, starting from this position (default for offset is 0)

- `length::Int`: lock length bytes only, starting from offset (default for length is 0)

- `whence::Int`: how to interpred the offset (default for whence is 0)

- `get::Int`: if set, then only test is performed if the file region can be locked

- `noblock::Int`: set, if you do not wish the lock to block

# Output

The call is always successful unless read/write error is encountered. Result will be 0 regardless if lock was granted or not.

One should check the return field `locked` to see if lock was granted. Unlocking always sets `locked` to true, the same goes for blocking requests, as they are always successful (sooner or later).

So with `result` of `0` checking the value of `locked` makes sense only for non-blocking locks and for `get` checks.

# Output Example
```
{
    result: 0,
    locked: true
}
```
"""),
(:newsletter_subscribe, """
	newsletter_subscribe(client::PCloudClient; kwargs...)

Subscribes an email for pCloud Newsletter.

If the email was not already verified, then a link is sent in the mail. After using the link, the email owner will verify his email.

Source: https://docs.pcloud.com/methods/newsletter/newsletter_subscribe.html

# Arguments

- `mail::String`: the mail that is eneterd to the Newsletter list

# Output

In the filed `verifymail` is `true` if a verify mail is sent.

# Output Example
```
{
    verifymail: true,
    result: 0
}
```
"""),
(:newsletter_check, """
	newsletter_check(client::PCloudClient; kwargs...)

Checks if the current logged usre is subscribed to pCloud Newsletter.

Source: https://docs.pcloud.com/methods/newsletter/newsletter_check.html

# Output

The filed `subscribed` is `true`, if the user was subscribed to the Newsletter.

The field `verified` is `true`, if the user had already verified his email, using a link, sent in a mail to his email address.

# Output Example
```
{
    subscribed: true,
    verified: false,
    result: 0
}
```
"""),
(:newsletter_verifyemail, """
	newsletter_verifyemail(client::PCloudClient; kwargs...)

Uses a `code` sent in a mail to the email, which the user had subscribed to the Newsletter. If the `code` is valid, then the user's email is marked as verified.

Source: https://docs.pcloud.com/methods/newsletter/newsletter_verifyemail.html

# Arguments

- `code::String`: code, sent in a mail to the user

# Output

The `email` that was marked as verified is set This is for security reasons.

# Output Example
```
{
    result: 0,
    email: "newsletter@pcloud.com"
}
```
"""),
(:newsletter_unsubscribe, """
	newsletter_unsubscribe(client::PCloudClient; kwargs...)

Uses a `code` sent in a mail to the email, which the user had subscribed to the Newsletter. If the `code` is valid, then the user's email is unsubscribed.

Source: https://docs.pcloud.com/methods/newsletter/newsletter_unsubscribe.html

# Arguments

- `code::String`: code, sent in a mail to the user

# Output

Always sends `result`=0, even if the user was never added to the Newsletter. This is for security reasons.

# Output Example
```
{
    result: 0
}
```
"""),
(:newsletter_unsubscribemail, """
	newsletter_unsubscribemail(client::PCloudClient; kwargs...)

Sends an email to the given `mail` with a code, that could be used to unsubcribe the email from the Newsletter.

This email is sent to a `mail` that was added to the newsletter, but it is not necessary to be verified.

Source: https://docs.pcloud.com/methods/newsletter/newsletter_unsibscribemail.html

# Arguments

- `code::String`: code, sent in a mail to the user

# Output

Always sends `result`=0, even if the email was never sent. This is for security reasons.

# Output Example
```
{
    result: 0
}
```
"""),
(:trash_list, """
	trash_list(client::PCloudClient; kwargs...)

Lists the contents of a folder in the `Trash`.

The root folder of the `Trash` has `id='0'`.

Outputs the `metadata` of the folder. This metadata will have `contents` field that is array of metadatas of folder's contents.

Note that the metadata from this function has the additional field `origparentfolderid` in the metadata. This is the folder, in which the file or folder was, before it was moved to `Trash`.

So the field `parentfolderid` is showing the position in the `Trash`.

Only files and folders that belong to the current user will be outputed from this method.

Recursively listing a `Trash` folder is not an expensive operation.

This method is very simillar to `listfolder`

Source: https://docs.pcloud.com/methods/trash/trash_list.html

# Optional Arguments

- `folderid::Int`: the id of the Trash folder. The default is 0 - the root of the Trash.

- `nofiles::Int`: If set, then no files will be included in the Trash list - only folders.

- `recursive::Int`: If set, then the list will be recursive - the subfolders will have their folders and files included.

# Output

On success returns the `metadata` and the `contents` of the folder from the `Trash`.

# Output Example
```
{
    result: 0,
    metadata: {
        thumb: false,
        path: "/",
        isfolder: true,
        isshared: false,
        ismine: true,
        modified: "Mon, 16 Sep 2013 12:10:32 +0000",
        created: "Mon, 16 Sep 2013 12:10:32 +0000",
        name: "/",
        folderid: 0,
        isdeleted: true,
        icon: "folder",
        id: "d0",
        contents: [
            {
                name: "Deleted folder",
                folderid: 236427,
                id: "d236427",
                origparentfolderid: 123,
                parentfolderid: 0,
                thumb: false,
                isfolder: true,
                isshared: false,
                ismine: true,
                modified: "Sat, 14 Dec 2013 13:37:33 +0000",
                created: "Tue, 03 Dec 2013 15:50:22 +0000",
                isdeleted: true,
                icon: "folder",
                contents: [ ]
            },
            {
                name: "Deleted file",
                id: "f76543",
                fileid: 76543,
                origparentfolderid: 6543,
                parentfolderid: 0,
                category: 3,
                icon: "audio",
                contenttype: "audio/x-mpegurl",
                hash: 17079372075467340000,
                size: 759,
                isfolder: false,
                thumb: false,
                isshared: false,
                modified: "Wed, 18 Sep 2013 10:18:46 +0000",
                created: "Wed, 18 Sep 2013 10:18:14 +0000",
                ismine: true,
                isdeleted: true
            }
        ]
    }
}
```
"""),
(:trash_restorepath, """
	trash_restorepath(client::PCloudClient; kwargs...)

For a desired file or folder from the `Trash`, calculates where to restore.

This method is granted that will choose such the destination folder, that `ismine` is `true`.

If the parent folder is also deleted, then this method will calculate the path by going to the parent of the folder. That way the file or folder will be restored at most at the root of the file system.

Also, if there are some name conflicts, then a new name will be generated, that is `Name (k)` , if there are `k-1` files with the same name.

Source: https://docs.pcloud.com/methods/trash/trash_restorepath.html

# Arguments

- `fileid::Int`: file id of the file that would be restored

- `folderid::Int`: folder id of the folder that would be restored

Use `fileid` or `folderid`

# Output

On success returns the follwing `metadatas`

- `metadata`: Information how the file or folder will look after restoring

- `destination`: Information about the calculated destination of the restored foldre

# Output Example
```
{
    result: 0,
    metadata: {
        name: "Deleted folder",
        id: "d56986",
        folderid: 56986,
        parentfolderid: 56980,
        isdeleted: true,
        ismine: true,
        icon: "folder",
        created: "Mon, 03 Feb 2014 15:02:56 +0000",
        modified: "Mon, 03 Feb 2014 15:03:13 +0000",
        isfolder: true,
        thumb: false,
        isshared: true
    },
    destination: {
        name: "The destination folder",
        id: "d56980",
        folderid: 56980,
        parentfolderid: 0,
        ismine: true,
        icon: "folder",
        created: "Fri, 31 Jan 2014 12:57:56 +0000",
        modified: "Mon, 03 Feb 2014 15:04:32 +0000",
        isfolder: true,
        thumb: false,
        isshared: true
    }
}
```
"""),
(:trash_restore, """
	trash_restore(client::PCloudClient; kwargs...)

Restores files or folders from the `Trash` back to the filesystem.

The destination, where the data will be restored can be automatically calculated via trash_restorepath or it could be specified by the user (use `restoreto` parameter).

If `folderid='0'`, then all data in the `Trash` will be restored, as close to their original positions, as possible. If `restoreto` is set, then all data in the `Trash` will be placed into this folder.

If the destination is a shared folder, then a user to which the folder was shared, will need CREATE access to the folder.

If the current user used space + the resotred files size is greater than the user quota, then this method will restore, until the first file that goes over quota is restored. Then it will raise an error.

Source: https://docs.pcloud.com/methods/trash/trash_restore.html

# Arguments

- `fileid::Int`: file id of the restored file

- `folderid::Int`: folder id of the restored folder

Use `fileid` or `folderid`

# Optional Arguments

- `restoreto::Int`: If given, then this folder will be chosen as a destination of the restored data.

- `metadata::Int`: If set and restoring a folder, then the metadata of the folder will have contents filled with the information about files and folders in the restired folder.

# Output

On success returns the `metadata` of the restored file or folder.

If the root of the trash is restored and `restoreto` is specified, then the metadata is shown for the `restoreto` folder.

Else if `restoreto` is not specified, then result is a list `restored` of `metadatas` of the restored files / folders.

# Output Example
```
{
    result: 0,
    metadata: {
        name: "Deleted folder",
        folderid: 236427,
        id: "d236427",
        parentfolderid: 0,
        thumb: false,
        isfolder: true,
        isshared: false,
        ismine: true,
        modified: "Sat, 16 Dec 2013 16:20:00 +0000",
        created: "Tue, 03 Dec 2013 15:50:22 +0000",
        isdeleted: false,
        icon: "folder",
        contents: [
        ]
    }
}
```
"""),
(:trash_clear, """
	trash_clear(client::PCloudClient; kwargs...)

Deletes

*permanently* files or folders from the `Trash`.

Files and folders deleted via this method cannot be restored.

If `folderid='0'`, then all data from the `Trash` will be removed.

Source: https://docs.pcloud.com/methods/trash/trash_clear.html

# Arguments

- `fileid::Int`: file id of the file that is removed from Trash

- `folderid::Int`: folder id of the folder that is removed from Trash

Use `fileid` or `folderid`

# Output Example
```
{
    "result": 0
}
```
"""),
(:collection_list, """
	collection_list(client::PCloudClient; kwargs...)

Get a list of the collections, that are owned from the current user.

Optionally, the items in the collections could be returned and the collections could be filtered by type.

The system collections of the current user are genereated on the first call of this method.

This method removes from the collection all items that could not be found at the time of invocation. Reasons are, for example, the files were moved to trash or there were in a shared folder, that now is not shared.

Source: https://docs.pcloud.com/methods/collection/collection_list.html

# Optional Arguments

- `type::Int`: Filter type of the collection. 1 is for playlists.

- `showfiles::Int`: If set, then contents of the collection will be filled with metadata of the files in the collection.

- `pagesize::Int`: If set and showfiles is set, then the items in contents will be limited to this count.

# Output

On success returns the `collections` and optionally the `metadata` of the first items in the collection in the field `contents`.

# Output Example
```
{
    "result": 0,
    "collections": [
        {
            "name": "my music",
            "id": 40,
            "ismine": true,
            "items": 8,
            "system": false,
            "type": "audio",
            "created": "Thu, 13 Feb 2014 12:34:22 +0000",
            "modified": "Mon, 17 Feb 2014 11:25:55 +0000",
            "contents": [ ]
        } ,
        { 
            "name": "Most Listened",
            "id": 38,
            "ismine": true,
            "items": 0,
            "system": true,
            "type": "audio",
            "created": "Wed, 12 Feb 2014 11:51:00 +0000",
            "modified": "Wed, 12 Feb 2014 11:51:00 +0000",
            "contents": [ ]
        } ,

        ...

    ]
}
```
"""),
(:collection_details, """
	collection_details(client::PCloudClient; kwargs...)

Get details for a given collection and the items in it.

Optionally, paging could be used for the results in the collection.

This method removes from the collection all items that could not be found at the time of invocation. Reasons are, for example, the files were moved to trash or there were in a shared folder, that now is not shared. For that reason, when paging is used, the page could have less results than the pagesize and more pages to be available.

Source: https://docs.pcloud.com/methods/collection/collection_details.html

# Arguments

- `collectionid::Int`: the id of the collection.

# Optional Arguments

- `page::Int`: the number of the page, for which results are shown.

- `pagesize::Int`: the size of the page.

Default page is 0, which is all items.

# Output

On success returns the `collection` and the `metadata` of the items in the field `contents`.

# Output Example
```
{
    "result": 0,
    "collection": {
        "id": 40,
        "type": "audio",
        "system": false,
        "ismine": true,
        "items": 11,
        "created": "Thu, 13 Feb 2014 12:34:22 +0000",
        "modified": "Tue, 18 Feb 2014 11:16:24 +0000",
        "name": "my music",
        "contents": [
            {
                "id": "f599457",
                "fileid": 599457,
                "name": "Demo Audio 2.mp3",
                "parentfolderid": 21383,

                "position": 1,
                "added": "Mon, 17 Feb 2014 15:53:48 +0000",

                "isshared": false,
                "category": 3,
                "ismine": true,
                "icon": "audio",
                "created": "Mon, 16 Sep 2013 12:10:32 +0000",
                "hash": 1682158607045670700,
                "isfolder": false,
                "contenttype": "audio/mpeg",
                "modified": "Mon, 16 Sep 2013 12:10:32 +0000",
                "size": 142376,
                "thumb": false
            },

            ...

        ]
    }
}
```
"""),
(:collection_create, """
	collection_create(client::PCloudClient; kwargs...)

Create a new collection for the current user.

Optionally, files could be given for the collection to fill it.

Source: https://docs.pcloud.com/methods/collection/collection_create.html

# Arguments

- `name::Int`: the name of the new collection.

# Optional Arguments

- `type::Int`: type of the collection.

- `fileids::String`: comma-separated list of files to fill the collection.

Default type is 1 - playlist.

# Output

On success returns the new `collection` and the `metadata` of the items in the field `contents`, if such were given.

Also field `linkresult` will be added, if there were files to fill the collection. For its structure look at `collection_linkfiles`. If the linking was unsuccessful, then this field will be `false`.

# Output Example
```
{
    "result": 0,
    "collection": [
        {
            "name": "my music",
            "id": 40,
            "ismine": true,
            "items": 8,
            "system": false,
            "type": "audio",
            "created": "Thu, 13 Feb 2014 12:34:22 +0000",
            "modified": "Mon, 17 Feb 2014 11:25:55 +0000",
            "contents": [ ]
        }
    ]
}
```
"""),
(:collection_rename, """
	collection_rename(client::PCloudClient; kwargs...)

Renames a given collection owned by the current user.

Source: https://docs.pcloud.com/methods/collection/collection_rename.html

# Arguments

- `collectionid::Int`: the id of the collection.

- `name::String`: the new name of the collection.

# Output

On success returns the modified `collection`.

# Output Example
```
{
    "result": 0,
    "collection": [
        {
            "name": "my music",
            "id": 40,
            "ismine": true,
            "items": 8,
            "system": false,
            "type": "audio",
            "created": "Thu, 13 Feb 2014 12:34:22 +0000",
            "modified": "Mon, 17 Feb 2014 11:25:55 +0000",
            "contents": [ ]
        }
    ]
}
```
"""),
(:collection_delete, """
	collection_delete(client::PCloudClient; kwargs...)

Delete a given collection owned by the current user.

System collections could not be deleted. In this case error `2065` (Collection not found.) will be raised.

Source: https://docs.pcloud.com/methods/collection/collection_delete.html

# Arguments

- `collectionid::Int`: the id of the collection.

# Output Example
```
{
    "result": 0
}
```
"""),
(:collection_linkfiles, """
	collection_linkfiles(client::PCloudClient; kwargs...)

Appends files to the collection.

The files will be added at the end of the collection. If you want to insert the files at another position, then link them via this method and then use `collection_move`.

This method preserves the relative order given in the fileids field.

Duplicates are not allowed to be met in the collections.

Source: https://docs.pcloud.com/methods/collection/collection_linkfiles.html

# Arguments

- `collectionid::Int`: the id of the collection.

- `fileids::String`: comma-separated list of ids of the files to be added.

# Optional Arguments

- `noitems::Int`: if set, then linkresult will be empty

# Output

On success returns the updated `collection`.

`linkresult` contains the result for all items, unless `noitems` is set. It has the format:

- `result::Int`: code of the operation. 0 means success, otherwise the file could not be linked.

- `fileid::Int`: the id of the file that is linked

- `message::String`: if an error occures, then this the message of the error. Not set, if successful.

- `metadata::metadata`: the metadata of the linked file, if linked successfully. The fields are added:position - where the item is added to the collectionadded - when the item was linked to the collection

# Output Example
```
{
    "result": 0,
    "linkresult": [
    {
        "fileid": "599457",
        "result": 0,
        "metadata": {
            "id": "f599457",
            "fileid": 599457,
            "contenttype": "audio/mpeg",

            "position": 9,
            "added": "Tue, 18 Feb 2014 11:16:24 +0000",

            "created": "Mon, 16 Sep 2013 12:10:32 +0000",
            "modified": "Mon, 16 Sep 2013 12:10:32 +0000",
            "hash": 1682158607045670700,
            "icon": "audio",
            "parentfolderid": 21383,
            "ismine": true,
            "isshared": false,
            "isfolder": false,
            "name": "Demo Audio 2.mp3",
            "category": 3,
            "thumb": false,
            "size": 1442376
        }
    },
    {
        "fileid": "123",
        "result": 2009,
        "message": "File not found."
    },

    ...

    ],
    "collection": {
        "id": 40,
        "name": "my music",
        "type": "audio",
        "ismine": true,
        "system": false,
        "items": 11,
        "created": "Thu, 13 Feb 2014 12:34:22 +0000",
        "modified": "Tue, 18 Feb 2014 11:16:24 +0000",
        "contents": []
    }
}
```
"""),
(:collection_unlinkfiles, """
	collection_unlinkfiles(client::PCloudClient; kwargs...)

Remove files from a current collection.

There are three methods to remove files from the collection:

all items in the collectionsremove fileids from the collectionremove items at given positionsThe priority is the method checks is position, then all , then fileids.

Source: https://docs.pcloud.com/methods/collection/collection_unlinkfiles.html

# Arguments

- `collectionid::Int`: the id of the collection.

# Optional Arguments

- `all::Int`: if set, all files from the collection are unlinked

- `positions::String`: comma-separated list of positions to be unlinked

- `fileids::String`: comma-separated list of fileids to be unlinked

*Note:* Use one of this parameters.

# Output

On success returns the modified `collection`.

# Output Example
```
{
    "result": 0,
    "collection": [
        {
            "name": "my music",
            "id": 40,
            "ismine": true,
            "items": 8,
            "system": false,
            "type": "audio",
            "created": "Thu, 13 Feb 2014 12:34:22 +0000",
            "modified": "Mon, 18 Feb 2014 14:25:55 +0000",
            "contents": [ ]
        }
    ]
}
```
"""),
(:collection_move, """
	collection_move(client::PCloudClient; kwargs...)

Changes the position of an item in a given colleciton, owned by the current user.

Source: https://docs.pcloud.com/methods/collection/collection_move.html

# Arguments

- `collectionid::Int`: the id of the collection.

- `item::Int`: the position of the item in the collection.

- `fileid::Int`: the id of the file to be moved in the collection.

- `position::Int`: the position to which the items to be placed.

# Output Example
```
{
    "result": 0
}
```
"""),
(:authorize, """
	authorize(client::PCloudClient; kwargs...)

This is a web page which starts the OAuth 2.0 authorization flow. On this page he user logs in to pCloud and then desides if to grant the access to your app.

After the user takes the decision to give or not access from your application to his profile information and personal data, they will be redirected to the URI specified bv `redirect_uri`.

OAuth 2.0 has two different authorization flows:

*Code flow* - returns a `code` via the `redirect_uri` redirect. This code after that should be converted inot a `bearer token` using oauth2_token method.

*Token (implicit) flow* - returns the `bearer token` via the `redirect_uri` redirect. It does not rquires your app to initiate a second call to pCloud API.

*Code flow* is recommended if the app is using a server.

*Token flow* is appropriate for pure client-side apps - such for mobile devices or based only on JavaScript.

Source: https://docs.pcloud.com/methods/oauth_2.0/authorize.html

# Arguments

- `client_id::String`: id of the app.

- `response_type::String`: code or token.

# Optional Arguments

- `redirect_uri::String`: where to redirect after approval, mandatory for token, optional for code (code will be displayed to the user in this case).

- `state::String`: opaque data that will be passed back to redirect_uri.

- `force_reapprove::Bool`: if set, will force re-approval even if the application is already approved by the user.

- `permissions::manageshares`: a comma (,) separated list. If set additional permissions will appear in the approval form. Currently the only option is

# Output

On approval redirects to:

*Code flow*

These parameters are pased in the query string (after ?)

- `code::String`: The authorization code that could be exchanged for a bearer token by calling oauth2_token

- `state::String`: The contents of the state parameter, that was passed.

redirect_uri?code=XXXXX&state=YYYYY

*Token flow*

These parameters are pased in the URI fragment (after #)- `access_token::String`: A token that could be used to call pCloud API methods.

- `token_type::String`: The type of the token (always bearer).

- `uid::Int`: The ID of the user, who gave access to the app.

- `state::String`: The contents of the state parameter, that was passed.

redirect_uri#access_token=XXXXX&token_type=bearer&

uid=11111&state=YYYYYY
"""),
(:oauth2_token, """
	oauth2_token(client::PCloudClient; kwargs...)

This method is used when an app is using the code flow. The app calls this method to obtain a bearer token, after the user had authorized the app.

This method expects the app's `key` and `secret`.

Also the `code` received from the redirect from oauth2_token is required.

Source: https://docs.pcloud.com/methods/oauth_2.0/oauth2_token.html

# Arguments

- `client_id::String`: - id of the application

- `client_secret::String`: - secret code for the application

- `code::code`: - code returned to the redirect from authorize page

# Output

After the `code` is validted, the method returns the object with fields:

- `access_token::String`: A token that could be used to call pCloud API methods.

- `token_type::String`: The type of the token (always bearer).

- `uid::Int`: The ID of the user, who gave access to the app.

# Output Example
```
{
    result: 0,
    access_token: "dghdghdj",
    token_type: "bearer",
    uid: 34535
}
```
"""),
(:uploadtransfer, """
	uploadtransfer(client::PCloudClient; kwargs...)

Does a file(s) transfer in way that creates and sends transfer links to receiver emails.

Source: https://docs.pcloud.com/methods/transfer/uploadtransfer.html

# Arguments

- `sendermail::String`: mail of the sender

- `receivermails::String`: mail(s) of the receivers(up to 20) separated by ,

# Optional Arguments

- `message::String`: short message(up to 160 characters) acting as a comment to the receivers

- `progresshash::String`: hash used for observing transfer progress

# Output Example
```
{
    result: 0
}
```
"""),
(:uploadtransferprogress, """
	uploadtransferprogress(client::PCloudClient; kwargs...)

Monitor the progress of transfered files.

Source: https://docs.pcloud.com/methods/transfer/uploadtransferprogress.html

# Arguments

- `progresshash::String`: hash defining the transfer, same as sent to uploadtransfer

# Output

Returns same data as uploadprogress.
"""),
]