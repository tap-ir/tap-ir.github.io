# About 

**TAPIR** (Trustable Artifacts Parser for Incident Response) is a multi-user, client/server, incident response framework based on the [TAP](https://github.com/tap-ir/) project. 

- It take as input  **files** (can be a **disk dump** or any kind of file), a **directory** containing different files (from a triage tool), or a disk **device**. It use different plugins to virtually extract data and metadata from those files, letting you access them in an homogenous way via a REST API, it also come with a search engine [TAP-QUERY](https://github.com/tap-ir/tap-query) that let you create complex query to filter data and metadata. 

- Server can be accessed remotely or locally via it's REST API, or via :

  - [TAPyR](https://github.com/tap-ir/tapyr) a python binding that can be used to create script to automate your investigation. 
  - [TAPyR-cmd](https://github.com/tap-ir/tapyr-cmd) unix like shell command.
  - [TAPIR-Frontend](https://github.com/tap-ir/tapir-frontend) a web UI.


- It's multiplateform and run on Linux, Mac OS X, and Windows.

This documentation is a user guide that will help you use and conduct incident response with TAPIR. 

?> You might also be interested in [bin2json](https://github.com/tap-ir/bin2json) a simpler tool also based on the [TAP](https://github.com/tap-ir/tap) library. **bin2json** can automatically and recursively extract **metadata** from files or devices to a **JSON** file that can be sent to a **siem** or analyzed with tool like [JQ](https://github.com/stedolan/jq).

## Download & installation 

Debian/Ubuntu package & Windows binary are available [here](https://github.com/tap-ir/tapir/releases)

To install the package in Debian or Ubuntu :

```bash
sudo dpkg -i tapir_0.1.0_amd64.deb 
```

!> You will certainly need to [install **TAPyR-cmd**](https://tap-ir.github.io/#/?id=installation) too.


## Building

For building instruction follow this [link](https://github.com/tap-ir/tapir#building).

## Running 

For instruction to launch the TAPIR server follow this [link](https://github.com/tap-ir/tapir#running).

# Concept

To understand how **TAPIR** work, it's good to understand some of the concept and terms related to this project.

## Tree and nodes

**TAPIR** is used to ingest some data comming from a disk dump, triage files, device, ... and virtually extract data and metadata from those files. Those data are internally represented by a tree. Each node of the tree could represent either a file or a directory. Even if a node is a file it can have children that represent sub files contained in the parent file. This can be used to represent a file system (eg. after parsing an NTFS disk dump or an MFT), but also for exemple a registry hive, or any other kind of data. 

The node can be accessed on the tree by using a path, like in tradional file system. 

## Attributes

Each node of the tree have [Attributes](https://tap-ir.github.io/docs/dev/rustdoc/tap/attribute/struct.Attributes.html). Those attributes can represent metadata, structure, or any kind of information related to a node.  

[Attributes](https://tap-ir.github.io/docs/dev/rustdoc/tap/attribute/struct.Attributes.html) is a container of [attribute](https://tap-ir.github.io/docs/dev/rustdoc/tap/attribute/struct.Attributes.html) which are themselve composed of a name and a [value](https://tap-ir.github.io/docs/dev/rustdoc/tap/value/enum.Value.html) of different type. 
An [attribute](https://tap-ir.github.io/docs/dev/rustdoc/tap/attribute/struct.Attributes.html) can point to an other attribute as a pointer can point to an other structure in the "C" language.

To represent an attributes path as a string, the parent-children relation is marked with a  point ('.').  For exampe, an ntfs file,  will contain a standard\_information attribute that himself will contain an accessed_time attribute with value of type time. The path representing this attribute will be 'ntfs.standard_information.access_time' 

## Plugins

Nodes and attributes are added in the tree by parser plugins. Some plugin like the **exif** plugin will only add information to existing node. For example the **exif** plugin will parse the content of an image containing exif information and will add some attributes to that node like 'exif.primary.model'. In the same way the **plugin** will add the calculated hash of a file to it's attribute.

Other plugins like the NTFS plugins will create node with specific attribute. The **NTFS** plugin will read data coming from an other file and will create new node representing the content of that file system, each nodes will also have atrtibute corresponding to their ntfs metadata. 

A last type of plugin exist, the "input" plugin, those pluginis are used to access data that are external to the **TAPIR** tree, and load them in that tree so they could be parsed by other plugins. For example the **local** plugin let you access the file present in the **TAPIR** server filesystem's, the **DEVICE** plugin can be used to read a raw device, or the **S3** plugin can be used to read file from an **S3** server.

Each plugins take specific argument as input, but generally a plugin take a path to the node that it will parse to extract some data and metadata.
 
**TAPIR** is part of the [TAP](https://github.com/tap-ir/) project and the files types it support is the same as the one of [TAP](https://github.com/tap-ir/) project. (When new parser plugin is added to [TAP](https://github.com/tap-ir/), **TAPIR** is updated to include the new plugin).

At time of writting this documentation this is the plugin included in **TAPIR** : 

| Name | Category | Description |
| ---- | -------- | ----------- |
| local |Input | Load files or directory from the filesystem |
| exif | Metadata | Extract EXIF info from file |
| hash | Metadata | Hash file attribute |
| s3 | Input | Load files from a s3 server |
| merge | Util | Merge files into one file |
| ntfs | File system | Read and parse NTFS filesystem |
| mft | File system	| Read and parse MFT file |
| magic | Metadata | Detect magic and file data compatible with plugins |
| prefetch | Windows | Parse prefetch file |
| partition | Volume | Parse MBR & GPT partition |
| lnk | Windows	| Parse lnk file |
| evtx | Windows | Parse evtx file |
| registry | Windows | Parse registry file |
| clamav | Malware | Scan file content with ClamAV | 
| device | Input | Mount a device |
| yara | Malware | Scan file content with Yara |


# Command line

To use TAPIR via command line remotely or localy, you have to install [TAPyR-cmd](https://github.com/tap-ir/tapyr-cmd).
TAPyR-cmd is a bunch of python script that are used like Unix commands. Some commands output result to text or binary that be piped to Unix command, and some other commands output JSON that can be piped to tool like [JQ](https://github.com/stedolan/jq).

## Installation

To install TAPyR-cmd run :

```bash 
pip install tapyr-cmd
```

## Bash completion

After installing [TAPyR-cmd](https://github.com/tap-ir/tapyr-cmd) you can activate bash completion by issung this command :

```bash
wget https://raw.githubusercontent.com/tap-ir/tapyr-cmd/main/tapyr-cmd-completion.bash
sudo mv tapyr-cmd-completion.bash /etc/bash_completion.d/ && sudo chmod 444 /etc/bash_completion.d/tapyr-cmd-completion.bash
```

## API key and remote access

If you changed the default **API KEY** of your **TAPIR** server (that's recommended), you must set that key as an environment variable, so the command line tool can use it to authenticate to the server. 


On Linux or MacOS X :

```bash
export TAPIR_APIKEY=newkey
```

If you're connecting to a remote **TAPIR** server, or if you changed the default port (3583) of the server, you also need to set the address of the server as an environment variable. 

```bash
export TAPIR_ADDRESS=127.0.0.1:3583
```

## Loading data

The first thing to do when the server is running is to load some data, that need to be analyzed, on the server.
TAPIR come with differents plugins, some of those plugins of type **input** have for goal to load data on the server.
At the moment three plugins of this kinds exist : 
  - `Local` who load files (can be a full disk dump, or any kind of files)  and directory recursively (can be a directory containing triage files)
  - `Device` who let you read the content of a block device directly (a harddisk, or nvme disk)
  - `S3` that can be used to read a file from an S3 server

?> The [scan]((https://tap-ir.github.io/#/?id=scan) command can also be used to load data and parse those data automatically.

### Local

To load a file wth `local` just run : 

```bash
xlocal file_name
```

To load all files recursively from a directory (eg. loading triage output) : 

```bash
xlocal directory_name
```

## Running plugins

### Scan

**Scan** is a powerfull script. By using it, you can avoid to manually launch any of the **TAPIR** plugins. **Scan** will load a dump, or a directory, and once those data are loaded it will automatically run other plugins to extract metadata from that files. 
For that, scan will run **TAPIR** **magic** plugin on each file, this plugin detect the type of the file and add that information as an attribute of the node. Then the script check if any of the **TAPIR** plugins is compatible with that file type. If a compatible plugin is found, it will run that plugin on the this file. That is done recursively, and thus can generate lot of data and can take a huge amount of RAM, but it ensure that the all files are processed and that maximum of metadata and data have been extracted. 

For example if you run scan on a disk dump, it will automatically load the file, run the partition plugin, to virtually extract partition from the disk, run the **ntfs** plugin if the disk is formated in **ntfs**, and run plugins for each other file compatible with **TAPIR** plugins, like **evtx** or **registry**. If the dump contain thousand of registry file, in any directory, for each of them a plugin will be launch. (See [listing tasks](https://tap-ir.github.io/#/?id=listing-tasks) to know how to list launched plugins).

To run the scan on a file, on the **TAPIR** server filesystem's :

```bash
xscan path_to_file_or_directory
```

If you already loaded some files just run :

```bash
xscan
````

### Running plugin manually 

To run a plugin just execute the script corresponding to the name of the plugin, parser plugin generally take as first argument the path to the file you want to extract. 

Example to extract the content of an **MFT** file loaded into **TAPIR** :

```bash
xmft /root/MFT
```

## Tasks

When a plugin is executed it's added to **TAPIR** scheduler that will execute it as soon as it can. 
By running a script like **scan** many tasks can added to the queue at the same time. A task is composed of a plugin name and some arguments passed to this plugin. 
Each task can have 3 states :  
  - waiting
  - running
  - finished

This state describe if they are waiting to be executed, they are currently being executed or if execution is finished. 
When a task is in the finished state, the result of the execution of the task is associated to it. 
The result of the task can be an error (could came from wrong argument provided to the plugin, parsing errors, ...) or some result specific to the plugin. 

### Listing tasks

To list all tasks with their argument just run the `ps` command

### Tasks summary

To display a summary of the number of tasks executed by each plugin use the `psstat` command : 

## Browsing 

Once your data are [loaded](https://tap-ir.github.io/#/?id=loading-data) and [parsed](running-plugins) by some plugins,
you will want to browse the **TAPIR** tree made of nodes (files and directories) and attributes (metadata and data).

### Listing files

To list file you can use `xls` (always prepend **/root/** before the name of the loaded files).

```bash
xls /root/cfreds_2015.dd/partition_2/ntfs/root/Windows/System32
```

?> The `ls` command, and others one, can use [bash completion](https://tap-ir.github.io/#/?id=bash-completion) (either localily or remotely,) that make them lot more convenient to use.

### Listing attributes

To list a file attribute you can use the`attr` command, like the `ls` command, by providing the path of any nodes in the tree.
It will output attributes information in the JSON format. To parse that information we recommend to use tool like [JQ](https://github.com/stedolan/jq)

To display the [attributes](https://tap-ir.github.io/#/?id=attributes) of the $MFT in raw JSON format :

```bash
xattr "/root/mydump.dd/partition_2/ntfs/root/\$MFT"
``` 

To display all [attributes](https://tap-ir.github.io/#/?id=attributes) of the $MFT via `JQ` :

```bash
xattr "/root/mydump.dd/partition_2/ntfs/root/\$MFT" | jq
```

To display the size of the $MFT :

```bash
./xattr "/root/cfreds_2015.dd/partition_2/ntfs/root/\$MFT" | jq .attributes.data.size
```

To display the access time contained in the standard information structure extracted by the **NTFS** or **MFT** plugins :

```bash
./xattr "/root/cfreds_2015.dd/partition_2/ntfs/root/\$MFT" | jq .attributes.ntfs.standard_information.accessed_time
````

!> We need to add **quote**  when there is space in the path of the file and **backslash** for special character like **$** to avoid them being interpreted by the shell.

### Adding attribute

You can also add your own attributes to a node. This can be used to share something you observed with other analyst. 
To do that use the `xattr` command followed by the attribute name, the attribute value, and the pass of the node : 

```bash
xattr tag malware /root/dump.dd/partition_2/ntfs/root/12345.exe
```

### Displaying file content

To display the content of a file on the console you can use the command `xcat` :

```bash
xcat /root/dump.dd/partition_2/ntfs/root/Users/desktop.ini
````

You can also pipe the content of a file to an other command. 
For example to display the content of the file as hexadecimal :

```bash
xcat /root/cfreds_2015.dd/partition_2/ntfs/root/pagefile.sys | xxd | less
```

### Downloading files

To download the content of a file you can simply use the download command : 

```bash
xdownload /root/cfreds_2015.dd/partition_2/ntfs/root/Windows/System32/config/SYSTEM
````

<!-- ### Uploading files-->

<!--To upload file to the -->


## Query & timeline

**TAPIR** integrate the [tap-query](https://github.com/tap-ir/tap-query) library to let create powerful query, that let you search precise stuff in all the data and metadata extracted by the plugins. You can search for some attribute name, value or search inside data (content of file). **TAPIR** also let you create timeline that integrate timestamp generated by the different parser plugins (ntfs, registry, event logs, exif, ...) . Each plugin newly integrated into **TAPIR** will automatically have it's timestamp attribute integrated into the timeline. 

Search and timeline are multithreaded and generally very fast to generate (few seconds) even if millions of attributes is present in the **TAPIR** tree. Searching for data, is generally IO bound and will depend of the speed of your disk, however we stronly recommend to use **TAPIR** with data stored on NVME disk. 

### Query syntax 

Each query is made of one expression (of a specified type) or multiple expressions separated by an operator. The constructed query can be passed to the `find` command that will return all nodes that match the query. 

|Expression     | value matched |
|---------------|---------------|
|name           | file name     |
|attribute.name | attribute name|
|attribute:'attribute\_name'|attribute name and attribute value|
|data           | file content  |

 
Type to specify for name and attribute : 

| Type | value matched                               |
-------|---------------------------------------------|
|(u)   | default, type to match string               |
|r     | regular expression                          |
|w     | wildcard (use ? and * to replace character) |
|f     | fuzzy matching                              |

Type to specify for data :

| Data type | value matched                                                   |
|-----------|-----------------------------------------------------------------|
| (r)       | default, search via regular expression on binary and UTF-8 text |
| t         |  search string inside UTF-8 or UTF-16 text                      |

Operator that can be used between expression :

   - and
   - and not
   - or

### Examples 

#### Finding files

Using the **name** expression, you can match on file name.

* Seach all files named **image1.jpg** :

```bash
xfind  "name == 'image1.jpg'"
```

* Search all files with an extension of type .jpg (lower case) using wildcard : 

```bash
xfind "name == w'*.jpg'"
````

* Search for files with a bame starting by image and with an underscore using wildcard : 

```bash
xfind "w'image?_*.jpg'
```

* Search file names containing an extension .jpg or .tiff using regexp : 

```bash
xfind "name == r'([^\s]+(\.(?i)(jpg|tiff))$)'"
```

* Search for files named image1.jpg or starting by image 2 : 

```bash
xfind "name == 'image1.jpg' or name == w'image2*'"
```

#### Searching for data

Using the **data** expression, you can match content of files.

* Search binary or text filex containing ascii character 'hello' :

```bash
xfind "data == 'hello'"
```

* Search files having ELF signature : 

```bash
xfind  "data == '\x7F\x45\x4C\x46'"
```

* Search UTF-8 or UTF-16 files containing 'икра' :  

```bash
xfind  "data == t'икра'"
```

#### Matching attributes

Using the **attribute.name** expression you can search for files having an [attribute](https://tap-ir.github.io/#/?id=attribute) matching a specific name. 

* Search for files with an 'exif' attribute (files parsed by the **exif** plugin) :

```bash
xfind "attribute.name == 'exif'"
```

* Search for files with an 'exif.primary.model' : 

```bash
xfind "attribute.name == 'exif.primary.model'"
```

* Search for a files with an attribute named "exif" something then "model", with wildcard :

```bash
xfind "attribute.name == w'exif.*.model'"
```

Using the **attribute:'attribute_name'** expression you can match for a value of a specific attribute.

* Search for files with an attribute named 'evtx.event.eventdata.imagepath' with a value containing the string 'powershell' :

```bash
xfind "attribute:'evtx.event.eventdata.imagepath' == w'*powershell*'"
```

* Search for files with an attribute name starting with evtx.event with value containing 'powershell' : 

```bash
xfind "attribute:w'evtx.event*' == w'*powershell*'"
```


* Search for files for which any of the attributes have a value containing the string 'powershell' :

```bash
xfind "attribute:w'*' == w'*powershell*'"
```


#### Creating timeline

To create a timeline you can use the `xtimeline` command. Just provide the starting date, the end date and the name of file where to output the timeline :


```bash
./timeline 2022-06-17T15:28:45 2022-07-01T15:28:45 mytimeline.csv
```

## Python scripting

For scripting in python, you can launch the `xshell` command. It will create a **TAPIR** session using the [TAPyR](https://github.com/tap-ir/tapyr) library. Or you can create this session manually, then you can start scripting by using the different function provide by the API.

### Connecting to the server

To connect manually just launch a python3 shell, import the [TAPyR](https://github.com/tap-ir/tapyr) library and create a session.
By default it will connect to localhost (127.0.0.1) on port 3583 using the default API key. You can connect to an other host and specify an api key by settings environment [variable](https://tap-ir.github.io/#/?id=api-key-and-remote-access) as we did to use the command line tool, or by passing the some arguments at the initialization of the Tapir object.

```python
from tapyr.api import Tapir

session = Tapir()
```

To connect to the IP "1.2.3.4" on port "1234" with key "mykey" : 

```python
from tapyr.api import Tapir

session = Tapir(address="1.2.3.4:1234", api_key="mykey")
```

### Using the API 

You can use the the node function to get a node of the tree : 

```python
from tapyr.api import Tapir

session = Tapir()
windows = session.node("/root/my_dump.dd/partition_2/ntfs/root/Windows")
```

This will return a python object from which you can directly access the node attributes, as python instance variable.

?> You can use python3 shell compection to access the attribute by using `tab` 

```python
>>> print(windows.ntfs.is_deleted)
False
>>> print(windows.ntfs.standard_information)
{'accessed_time': '2015-03-25T14:50:50Z', 'altered_time': '2015-03-25T14:50:50Z', 'class_id': 0, 'creation_time': '2009-07-14T03:20:08Z', 'mft_altered_time': '2015-03-25T14:50:50Z', 'version_maximum_number': 0, 'version_number': 0}
>>> print(windows.ntfs.standard_information.accessed_time)
2015-03-25T14:50:50Z
```

For other API functions description look at the [TAPyR](https://github.com/tap-ir/tapyr) project.

### Using query 

You can use [query](https://tap-ir.github.io/#/?id=query-syntax) directly from the API to search for specific files.
The query API function take the query as first parameter and as second optional parameter the path from which the query will be applyied. (If the second parameter is not provided, it will search from the root of the tree).
The query function will not return a list of nodes but a list of "node\_id". To get a node from an id you can use the `node\_id` API function.

* To search for all files with a .exe suffix from the root of the tree and display the files name :

```python
>>> for node_id in session.query("name == w'*.exe'"):
...   print(session.node_id(node_id).name())
...
```

* Each function called from the session object will create a request to the server, to avoid to make too much request, you can use the 'nodes\_by\_id' function that take a list of nodes\_id and return a list of nodes. 

```python
>>> for node in session.nodes_by_id(session.query("name == w'*.exe'"), name=True):
...    print(node.name())
...
```

### Example : Downloading all files that match a query

This python script take a [query](https://tap-ir.github.io/#/?id=query-syntax) as first argument and download files that match a query to the directory specified as second argument.

```python
#!/usr/bin/python3 
from tapyr.api import Tapir

session = Tapir()

if len(sys.argv) == 3:
  path = sys.argv[2]
  for node in session.nodes_by_id(session.query(sys.argv[1]), name=True, path=True):
    try:
      b = session.download(node.id, path + "/" + node.name())
    except Exception:
      print("Can't download file : " + node.path)
```

You can save this script in a file name 'extract.py' and use it to download all file with '.exe' suffix, in the 'executable' directory (you must create the 'executable' directory in the same directory than the script before launching it) :

```bash
./extract.py "name == w'*.exe'" executable/
```

If you previously runned the magic plugin or the scan command on the server, to detect file type, you can use the script we just write, to extract all files detected has executable even if the extension is not '.exe' by using the 'datatype' attribute : 

```bash
./extract.py "attribute:'datatype' == 'application/x-executable'" executable/
```
 
### Example : Searching powershell script in windows event log

This script use [query](https://tap-ir.github.io/#/?id=query-syntax) to search for powershell scripts in windows events logs and display information about the event and the powershell script :  

```python
session = Tapir()

query = session.query("attribute:'evtx.event.eventdata.imagepath' == w'*powershell*'")
for node_id in query:
  path = session.path(node_id)
  node = session.node_by_id(node_id)
  try:
    print("file :", path)
    print("host :", node.evtx.event.system.computer)
    print("created :", node.evtx.event.system.timecreated)
    print("event id:", node.evtx.event.system.eventid)
    print("account name :",  node.evtx.event.eventdata.accountname)
    print("service name :", node.evtx.event.eventdata.servicename)
    print("sid :", node.evtx.event.system.security)
    print("executed by :", node.evtx.event.system.execution)
    print("data :", node.evtx.event.eventdata.imagepath)
  except Exception as e :
    print(e)

query = session.query("attribute:'evtx.event.eventdata.scriptblocktext' == w'*'")
for node_id in query:
  path = session.path(node_id)
  node = session.node_by_id(node_id)
  try:
    print("file :", path)
    print("host :", node.evtx.event.system.computer)
    print("created :", node.evtx.event.system.timecreated)
    print("event id:", node.evtx.event.system.eventid)
    print("sid :", node.evtx.event.system.security)
    print("executed by :", node.evtx.event.system.execution)
    print("data :", node.evtx.event.eventdata.scriptblocktext)
  except Exception as e:
    print(e)
```

# Web UI 

[TAPIR-Frontend](https://github.com/tap-ir/tapir-frontend) is a full featured web user interface directly integrated into the **TAPIR** binary. The interface let you interact with a distant [TAPIR](https://github.com/tap-ir/tapir) server, browse files, directories, search and filter data, create timeline, visualize data, launch plugins, download files ... and a lot of other cool stuff ! 

## Login 

Just launch a browser and connect via http (or https if set in the **TAPIR** configuration) to the address and port set in the server configuration. (By default http://127.0.0.1:3583/) 

?> When you run the server, if available, a browser will be automatically launched and connected to the Web UI. 

Once connected just enter the API key, set in the server configuration, to loggin (default is 'key'). 

![Frontend login](login.jpg)


## Overview

![Overview](overview.jpg)

The main window of the UI is composed of a [toolbar](http://tap-ir.github.io/#/?id=toolbar), and different tabsets and [windows](http://tap-ir.github.io/#/?id=window). 

## Toolbar

The toolbar is on the top of the main window, it's composed of a serie of buttons.
![Toolbar](toolbar.jpg)

### Launching new window

By default when you connect to the web ui, one of each type of window (browser, search, timeline, tasks, plugins) is already launched.
If you need you can click one of the corresponding toolbar button to create a new window of that type. This is handy to compare some directories, 
or keep the result of a launched search or timeline. When a new window is launched it will be added to the current tab group. 
If needed you can detab and [move](https://tap-ir.github.io/#/?id=moving-window) the window. 

### Fullscreen

The ![fullscreen](fullscreen.jpg) button will set your browser in fullscreen mode, click again on the button or press `esc` on Firefox to exif fullscreen.

### Help 

The ![help](help.jpg) button open a new window that bring you to this documentation (if your server have internet access).

## Window

The web interface is composed of different windows that let you interact with **TAPIR** and visualize data.

### Moving Window

Each window can be moved to an other tabset or can be detabbed and be placed anywhere on the screen.
To do that, left click on the window then at the same time move the window where you want to place it.

<!-- XXX screenshoot/gif anime -->

### Renaming window

You can rename windows by double-clicking on their name, this can be useful to find them more easily.

![rename](rename.jpg)

### Maximizing tabset

You can maximize a specific tabset by clicking on ![maximize](maximize.jpg), on the top right corner of the window,
this can be helpful to see more data at once. Click back on the button to restore the tabset.

### Popout the viewer

The [viever](https://tap-ir.github.io/#/?id=viewer) is a specific window that display file content, there is only one viewer window and you can't launch an other one. It's content is updated when you click a file on any opened browser. The viewer can be poped out to, for example, be displayed on a second screen.
To do that click on ![popout](popout.jpg) on the top right corner of the window. To restore the browser in the main window, just close the popped out window.

## Browser

The browser let you browse and interact with the nodes (files and directory) and their attributes, in a tree view, that look like a classical file explorer.

![browser](browser.jpg)

The browser is divided into four part : the toolbar on the top, the directory tree on the left, the file browser on the center, and the attribute panel in the right.

### Browser toolbar

![browser-toolbar](browser-toolbar.jpg)

The toolbar is divised in a range of button and a center editable bar.

- Click ![browser-toolbar-arrow](browser-toolbar-arrow.jpg) to go back to the parent directory.
- Click ![browser-toolbar-home](browser-toolbar-home.jpg) to go back to the root directory.
- Modify ![browser-toolbar-text](browser-toolbar-path.jpg) and click enter to go to that directory.
- Click ![browser-toolbar-column](browser-toolbar-column.jpg) to edit columns.
- Click ![browser-toolbar-export](browser-toolbar-export.jpg) to export rows selected in the central panel, to JSON or CSV, or download a bunch of selected files into a zip archive.

### Directory tree

![directory-tree](directory-tree.jpg)

The directory tree let you expand any nodes that have children by clicking on ![tree-arrow](tree-arrow.jpg), if you click on the name of a directory, the list of it's children will appear on the center panel.

### File browser

![file-browser](file-browser.jpg)

The file browser show you a table with the current children nodes (files and directories) contained in the current path. 
If you click on any nodes on the table (files or directories), it's attributes will be shown on the right panel, if this node have data (for example, if it's a file of file system), their data will be displayed by the file [viewer](https://tap-ir.github.io/#/?id=viewer).

When you double click a directory, the current path will change to the one of that directory.

#### Column

##### Change order

You can change column order via drap and drop, just left click on the name of the column, you want to move, while moving the column.

![move-column](file-browser-drag-drop.jpg)
 
##### Sorting

![sorting](file-browser-sorting.jpg)

You can sort the column by clicking on the arrow on the top of the column, click again to sort to the other order, and click a third time to cancel sorting. 

#### Searching

![column-search](file-browser-filtering.jpg)

You can search data on a column, or a sorted column, by clicking on the magnyfying glass, then enter your search term  and then click search. The text you have searched will be highlighted. You can click reset to cancel the search.

![column-search-filter](file-browser-search-filter.jpg)

You can go further and click filter, to filter your current search. 

#### Selection 

![selection](file-browser-selection.jpg)

You can select nodes (files and directories) by clicking on the checkable box on the far left column. Once nodes are selected you can [export](https://tap-ir.github.io/#/?id=export) your data.

##### Export

To export selected data, click on ![export](browser-toolbar-export.jpg) button in the toolbar.

![exporting](export-selection.jpg)

You can choose to export the current selection (nodes with checked boxes) by clicking 'selection' or export all nodes in the current view by clicking 'all'.

Then you can choose to export to CSV or JSON format : 

![export-json](export-json.jpg)

You can specify the name of output filed, and then click 'ok', that file will be automatically downloaded by your browser. When you export to JSON all attributes for the selected nodes will be exported. When you export to CSV only the currently selected columns will be exported, the order of the column in the current view will be preserved.

?> You can add new column by right clicking on the [attributes tree](https://tap-ir.github.io/#/?id=attributes-tree). 

You can also download all selected file to a zip archive by clicking on 'zip'.

![export-zip](export-zip.jpg)

You can choose the name of the archive, and if you want you can cypher the archive by adding a password before clicking the 'ok' button.

#### Menu 

By right clicking on a node you will popup a menu that let you do many things, like downloading file, copy data, run plugins, add attribute ...

##### Open in new browser

![menu-open](menu-open.jpg)

The open in new browser button will launch a new browser pointing to the current path.

##### Copy

![menu-copy](menu-copy.jpg)

By clicking the copy button you can copy the currently selected nodefull path, or the currently selected text in the clipboard.

?> Copying the node path is useful when, at the same time, you use [TAPyR-CMD](https://github.com/tap-ir/tapyr-cmd) as you can paste the paste of the node to the shell to run some command on it.

##### Download

![menu-download](menu-download.jpg)

By clicking the download button you can download the current file. 

?> There is no file size limit, and you can download a full dump or a partition as the file is streamed.

##### Plugins

![menu-plugin](menu-plugin.jpg)

The plugin button let you run any of the **TAPIR** plugin. When selecting a plugin in the menu, a window will pop-up : 

![plugin-hash](plugin-hash.jpg)

This window is dynamically created, so you can enter any of the plugin argument. The default node on which the plugin will be applyied will be automatically filled with the currently selected node.

?> When a plugin is added to the [TAP](https://github.com/tap-ir/tap) library and to [TAPIR](https://github.com/tap-ir/tapir), it will be automatically added to this menu without needing the developer to add anything. 

##### Viewer

![menu-viewer](menu-viewer.jpg)

This interface as a dedicated [viewer](https://tap-ir.github.io/#/?id=viewer) window, but you can also launch a viewer on a new window by selecting one of the viewer via this menu.

##### Add attribute

![menu-add](menu-add-attribute.jpg)

You can add attribute on any node by clicking the 'add attribute' button.

![attribute-window](attribute-window.jpg)

A popup will shown where you can specify the name and the value of the attribute.

?> Adding attribute is a good way to share some information with other investigator connected to the same **TAPIR** server.


### Attributes tree

![attribute-tree](attribute-tree.jpg)

The attribute tree is the right panel in the browser.
It let you display the different attributes of the current node. 
You can click the ![attribute-tree-arrow](attribute-tree-arrow.jpg) button to expand an attribute and see it's children.  

### Menu 

You can right click on an attribute to display a menu.
This menu let you : copy the current attribute name, value, attribute and value or the current slected text.

?> This can be usefull to copy some valuable artifacts to your report !

You can also click the 'add column button', to add a column on the file browser for the currently selected attribute.

?> It's really helpful to add column when you're browsing data exported by the registry or the evtx plugin, as attributes for those format will not be displayed as column by default.

## Search

![search](search.jpg)

The search window is a table which look a lot like the [browser](https://tap-ir.github.io/#/?id=browser), except it doesn't have a left panel with a tree viewer, and also have specific button that let you create powerfull query to search for specific data.

Look at the [browser](https://tap-ir.github.io/#/?id=browser) documentation to know how to add, filter, and search on column, how to export data, ...


### Manual query

You can create and run your own query with the same syntax as the one used by the [find](https://tap-ir.github.io/#/?id=query-syntax) command line tool. Simply enter your query and it the 'enter' key or the ![search-button](search-button.jpg) button.

### Wizard

An easier way to create your query is to click on the ![search-wand](search-wand.jpg) button. 

![query-editor](query-editor.jpg)

This will popup a wizard that will guide you to create your query. For more information on the differents fields refer to the [find](https://tap-ir.github.io/#/?id=query-syntax) command documentation.

### Result

Once you hit the 'enter' key or click the ![search-button](search-button.jpg) button, the search will begin, once finished a popup with the number of result will appear : 

![search-result-popup](search-result-popup.jpg)

The number of results found will also appear on the far right of the toolbar : 


![search-result-tool](search-result-tool.jpg)


## Timeline

![timeline](timeline.jpg)

The timeline window let you easily create a timeline and export it's result.
It's a table which look a lot like the [browser](https://tap-ir.github.io/#/?id=browser), except it doesn't have a left panel with a tree viewer, and also have specific button that let you specify the range date of your timeline.

![timeline-range](timeline-range.jpg)

To create your timeline select a time range via the calendar and then hit the 'enter' key or click the ![search-button](search-button.jpg) button.


### Result

Once your timeline is created a popup will appear : 
 
![timeline-result-popup](timeline-result-popup.jpg)


The number of results found will also appear on the far right of the toolbar : 
![timeline-result-tool](timeline-result-tool.jpg)

## Viewer

![viewer](viewer.jpg)

The viewer window let you display the data of the currently selected node, in any of the browser, in different format. There is only one instance of the viewer window for each of the browser but you can open a viewer in it's own window by using the [browser menu](https://tap-ir.github.io/#/?id=menu).

?> You can [popout](http://tap-ir.github.io/#/?id=popout-the-viewer) the viewer to put it on a second screen or in an other area. 

By default the 'auto' mode is selected, it will select for you the right viewer depending of this conditions :
  - If the magic plugin or the scan command was run it will use the detected file type to select which viewer to launch. (The magic plugin export the type in the 'datatype' attribute)
  - It will use the extension of the file to select the right viewer
  - If the file type is not handled by any plugin it will display the file as hexadecimal 

You can also select a specific type by clicking on the button corresponding to the type you want to force for that file.

?> Don't forget to click the 'auto' button again if you have forcde some visualization as the next file you click, on any browser, will use the same viewer. 

This table list the implemented viewer and the corresponding datatype and extension their are compatible with :

|Viewer| Extension | Datatype|
-------|-----------|---------|
|Text | txt, htm, html| text|
|Pdf | pdf | application/pdf |
|Image| jpeg, jpg, gif, bmp | image |
|Video| mp4, webm, 3gp, mov, mpg, ogg | video/mp4 |
|Word| docx | application/docx |
|Excel| xlsx, xls | application/xls | 
|Csv| csv | application/csv |

## Tasks

![tasks](tasks.jpg)

The tasks window let you see each plugins that was launch on the **TAPIR** server. The argument provided to each of the plugin and the status of the task associated to the plugin (waiting, running, finished).

Like in the browser you can [sort](http://tap-ir.github.io/#/?id=sorting), [search](http://tap-ir.github.io/#/?id=searching) and [filter](http://tap-ir.github.io/#/?id=searching) the different columns.

?> You can click on an argument file name to automatically open a browser showing the directory containing that file !

### Plugin results

You can see the results or errors returned by any plugins by double-clicking on the 'result' column of the corresponding plugin row. 

![task-result](task-result.jpg)


## Plugins

![plugins](plugins.jpg)

This window simply show you all plugins supported by your **TAPIR** server instance, the category of each plugins and a description of the plugin.

# Video 

Here is a talk about TAPIR presentend at [pass-the-salt 2022](https://2022.pass-the-salt.org/)

<iframe width="720" height="530" src="https://passthesalt.ubicast.tv/permalink/v126400010276dios5ji/iframe/" allowfullscreen="allowfullscreen" allow="autoplay"></iframe>
