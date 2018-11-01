# jucardi/onedrive

Minimal size OneDrive client in docker using https://github.com/skilion/onedrive

This image is smaller than most out there created for the same purpose since it uses a multi-stage Dockerfile, ensuring the final image only contains the essential components installed.

This image also allows to run multiple OneDrive clients in a single container.

## Getting started

### Initializing OneDrive accounts

You'll need to run the container interactively the first time so you can generate an authorization token for your container.

To do this

#### 1) Run the following command in the terminal

```bash
docker run -it \
    --restart=always \
    -v [ path to config dir ]:/config/[ config name ] \
    -v [ path to data dir ]:/data/[ data name ] \
    jucardi/onedrive
```

- **[ path to config dir ]**: This is the path to a directory of your choosing where the OneDrive client will store the configuration
- **[ path to data dir ]**: The directory where you would like your OneDrive data to be synchronized.
- **[ config name ]**: You can use configuration names to have multiple accounts synchronized. Use a unique name per OneDrive account you'd like to synchronize
- **[ data name ]**: This value must be the same as `[ config name ]` unless you provide your own configuration file inside the configuration directory. We'll talk about it in the advanced configuration section.

##### Example setting up a single account

```bash
docker run -it \
    --restart=always \
    -v ~/MyOneDrive/config:/config/MyOneDrive \
    -v ~/MyOneDrive/data:/data/MyOneDrive \
    jucardi/onedrive
```

##### Example setting up multiple accounts

```bash
docker run -it \
    --restart=always \
    -v ~/MyPersonalOneDrive/config:/config/PersonalOneDrive \
    -v ~/MyPersonalOneDrive/data:/data/PersonalOneDrive \
    -v ~/MyBusinessOneDrive/config:/config/BusinessOneDrive \
    -v ~/MyBusinessOneDrive/data:/data/BusinessOneDrive \
    jucardi/onedrive
```
Notice that there are two volume mounts per account. This must always be the case.

#### 2) Authorize the account

After running the command in the terminal, you will get the following prompt:

```
Authorize this app visiting:

https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=22c49a0d-d21c-4792-aed1-8f163c982546&scope=files.readwrite%20files.readwrite.all%20offline_access&response_type=code&redirect_uri=https://login.microsoftonline.com/common/oauth2/nativeclient

Enter the response uri:
```

1) Copy the URL and paste it in your browser.
2) Authenticate with your OneDrive account
3) After authenticating, you will be redirected to a blank page, copy the URL, it should be something similar to `https://login.microsoftonline.com/common/oauth2/nativeclient?code=M00112233-aabb-ccdd-eeff-001122334455`
4) Paste the code into the terminal and press ENTER

After following these steps, the client should start synchronizing your data (if you configured multiple accounts, you will have to repeat this for each account).

Once the synchronization is done, the container will exit.

If you used the `--restart=always` flag, you don't need to do anything else, the container will restart without the interactive mode, and keep your directory synchronized.

## Advanced configuration

### The `config` file
The main configuration file for the OneDrive client is named `config` and should be stored inside the configuration directory

This file contains two fields:

- **`skip_file`**: Indicates file patterns separated by `|` that the OneDrive client will ignore, you can indicate here system files such as `.DS_Store` on Mac OS that you don't want synchronized in the cloud.
- **`sync_dir`**: Indicates the directory inside the container where the data will be synchronized. When the configuration file is generated automatically, this field is set to `/data/[ config name ]`, which is why `[ config name ]` and `[ data name ]` need to be the same if the configuration is meant to be generated.

##### Configuration Example
```
skip_file = ".*|~*|.DS_Store|._*"
sync_dir = "/data/onedrive"
```

### The `sync_list` file for selective sync
If you would like to synchronize some of the directories in your OneDrive rather than the full drive, you may create a text file inside your configuration directory called `sync_list`. Each line should represent a relative path in your OneDrive.

##### Example
```
Backup
Documents/latest_report.docx
Work/ProjectX
notes.txt
```