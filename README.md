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

## Love feedback!
Let us know if you like this! [We're only one tweet away!](http://twitter.com/slowlanetools)

## Status
Current able to list most items, moving on to create & delete

`gem install slowlane`

results in binaries: 
- `slowlane-itunes`
- `slowlane-portal`
- `slowlane-fabric`
- `slowlane-ipa` (NOTE: this might change to a more generic `slowlane-ios` command)

## Changes
- 1.2.3: (fabric) invite and resend_invitation tester
- 1.2.2: (portal) add_device to provisioning profile
- 1.2.1: (fabric) list all devices
- 1.2.0: (fabric) list testers, list devices of tester, list members
- 1.1.1: fix missing mechanize gem
- 1.1.0: added slowlane-fabric (organization, tester, apps)
- 1.0.0: first release 

## Kudos
- [Fastlane](https://github.com/fastlane/fastlane)
- [Shenzhen](https://github.com/nomad/shenzhen)
- [Atlantispro](https://github.com/Legoless/Atlantis)

### Working
#### environment vars
- `SLOWLANE_ITUNES_USER`
- `SLOWLANE_ITUNES_PASSWORD`
- `SLOWLANE_ITUNES_TEAM`
- `SLOWLANE_PORTAL_USER`
- `SLOWLANE_PORTAL_PASSWORD`
- `SLOWLANE_PORTAL_TEAM`
- `SLOWLANE_FABRIC_USER`
- `SLOWLANE_FABRIC_PASSWORD`
- `SLOWLANE_FABRIC_TEAM`

#### Portal
- `slowlane-portal app list`
- `slowlane-portal app create <bundle_id> <name>`
- `slowlane-portal app delete <bundle_id>`
- `slowlane-portal certificate list`
- `slowlane-portal device list`
- `slowlane-portal profile list`
- `slowlane-portal profile decode <provisioningfile>`
- `slowlane-portal profile add_device <bundle_id> <udid>`
- `slowlane-portal profile download`
- `slowlane-portal psn list`
- `slowlane-portal team list`

#### Itunes
- `slowlane-itunes app list`
- `slowlane-itunes app info`
- `slowlane-itunes team list`
- `slowlane-itunes tester list`
- `slowlane-itunes build list`
- `slowlane-itunes build upload <bundle_id> <ipa_file>`

#### Fabric
- `slowlane-fabric app list`
- `slowlane-fabric tester list`
- `slowlane-fabric device list`
- `slowlane-fabric tester devices <email>`
- `slowlane-fabric tester resend_invitation <email> <bundle_id>`
- `slowlane-fabric tester invite <email> <bundle_id> <group_id>`
- `slowlane-fabric organization list`
- `slowlane-fabric member list`

#### Ipa
- `slowlane-ipa info <ipa_file>`

### Todo
#### Overall
A lot is still focusing on the happy path , we need to catch better the errors and deal with it
- output-format=csv
- output-file
- sort-field : 
- filter
- tempdir
- all options should be also pickingup env vars
- configfile

#### Portal
- create|delete certificate
- create|delete device
- create|delete profile
- combine priv & public profile -> pem,pk12
- add device to profile
- remove device to profile

#### Itunes
- create|delete tester
- create | submit | delete app
- all other commands

#### Fabric
- create|delete|list groups
- create|delete
- add device

#### Playstore
- all commands
