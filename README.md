# Slowlane
## Description
> The philosophy is never to be clever but the user in control and ask him to clarify rather than making a clever choice.

it's like [fastlane tools](https://fastlane.tools) but without the magic.

## Why ? 

Fastlane is great but it makes a lot of assumptions:
- hey let's sync all your provisioning profiles
- when you add a device, let's add it to all provisioning profiles by default
- let's use a fastfile
- let's store your user:password in your keychain
- ....

Don't get us wrong, we think fastlane is  **great** , but we are one of those who don't like suprises.

We leverage 'spaceship' library and will continue to work on that to have a shared 

## Status
Real alpha , as we are still exploring the spaceship api

### Working
#### environment vars
- `SLOWLANE_ITUNES_USER`
- `SLOWLANE_ITUNES_PASSWORD`
- `SLOWLANE_ITUNES_TEAM`

- `SLOWLANE_PORTAL_USER`
- `SLOWLANE_PORTAL_PASSWORD`
- `SLOWLANE_PORTAL_TEAM`

#### Portal
- `slowlane-portal app list`
- `slowlane-portal certificate list`
- `slowlane-portal device list`
- `slowlane-portal profile list`
- `slowlane-portal psn list`
- `slowlane-portal team list`

#### Itunes
- `slowlane-itunes app list`
- `slowlane-itunes app info`
- `slowlane-itunes team list`
- `slowlane-itunes tester list`
- `slowlane-itunes build list`

### Todo
#### Overall options
- output-format=csv
- output-file
- sort-field : 
- filter
- tempdir
- all options should be also pickingup env vars
- configfile

#### Portal
- create|delete app
- create|delete certificate
- download certificate
- create|delete device
- create|delete profile
- decode profile to list cert & devices
- download profile
- combine priv & public profile -> pem,pk12
- add device to profile
- remove device to profile

#### Itunes
- create|delete tester
- create | submit | delete app
- build upload
- all other commands

#### Playstore
- all commands

#### Crashlytics
- ipa check
- upload
