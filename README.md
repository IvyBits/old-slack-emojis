# Old Slack Emojis

Bring back old emojis to new Slack!

## What is this?
In February 2018, Slack pushed a change making Google emojis used on all platforms, instead of the older Apple emojis.

### Before change

![](https://i.imgur.com/oQYpzcH.png)

### After change

![](https://i.imgur.com/46NPVv2.png)

This patch reverses this change, and brings back the loveable Apple emojis to new Slack clients.

## Installation
Installation varies depending on if you're using the Slack webapp or desktop client. A patch for mobile app versions of Slack is not
within the scope of this project.

### Browser client

For browser clients, install an extension like Stylish ([Firefox](https://addons.mozilla.org/en-US/firefox/addon/stylish/),
[Chrome](https://chrome.google.com/webstore/detail/stylish-custom-themes-for/fjnbnpbmkenffdnngjfgmeleoegfcffe?hl=en)),
and install [this](https://userstyles.org/styles/155342/old-slack-emojis) style.

### Desktop client
#### Linux and Mac
Quick & dirty:

```shell
curl -sSL https://old-slack-emojis.cf | sudo bash
```

Alternatively, you can download and run
[the installation script](https://raw.githubusercontent.com/Xyene/old-slack-emojis/master/old-slack-emojis.sh) from this repository.

#### Windows
Download and run [the installation script](https://raw.githubusercontent.com/Xyene/old-slack-emojis/master/old-slack-emojis.bat)
from this repository.

The script won't work with the Windows Store version of the Slack app. The Windows Store version is write-protected and can't be
injected by this script. The version downloaded [from Slack's website](https://slack.com/downloads/windows)
should, however, work.

## Uninstallation
To uninstall, run the appropriate script with `-u` as a flag.

## Updating Slack
old-slack-emojis injects some code into the Slack client, which may be overwritten when Slack updates. If you start seeing the new
emojis, rerunning the installation script should fix things.

## "Cannot find Slack installation"

If you've installed Slack in some exotic place, the script might not find the installation by itself or it might find the
wrong installation. In such cases, you need to specify the location of Slack's `app.asar.unpacked/src/static` folder as a parameter:

```shell
sudo bash old-slack-emojis.sh /My_Apps/Slack.app/Contents/Resources/app.asar.unpacked/src/static
```

```shell
old-slack-emojis.bat E:\My_Apps\slack\app-2.5.1\resources\app.asar.unpacked\src\static
```

## Credits
old-slack-emojis uses the same injection mechanism as [math-with-slack](https://github.com/fsavje/math-with-slack), without which
a lot more time would have gone into figuring out how to get the old spritesheet injected. Thanks!
