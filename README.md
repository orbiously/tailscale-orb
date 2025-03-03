# Tailscale Orb


[![CircleCI Build Status](https://circleci.com/gh/orbiously/tailscale-orb.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/orbiously/tailscale-orb) [![CircleCI Orb Version](https://badges.circleci.com/orbs/orbiously/tailscale.svg)](https://circleci.com/orbs/registry/orb/orbiously/tailscale) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/orbiously/tailscale-orb/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)


This orb will allow users to connect the build-host to a [Tailscale Tailnet](https://tailscale.com/kb/1151/what-is-tailscale/). The build-host will then be able to communicate _privately_ with any Tailscale host in the same Tailnet via a peer-to-peer mesh network.

You can then also use the remote Tailscale host as a bastion/jump host to relay the traffic from your Tailscale network onto your physical subnet.

**This is an “executor-agnostic” orb; there is only one set of commands which can be used on any supported executor. The orb’s underlying code handles the OS/platform detection, and runs the appropriate OS-specific bash commands.**


---

## Executor support

| Linux (`machine`)  | Windows | macOS  | Docker |
| :---: | :---: | :---: | :---: |
| :white_check_mark:  | :white_check_mark:  | :white_check_mark:  | :white_check_mark:  |

## Requirements

- You need to have an existing [Tailnet](https://tailscale.com/kb/1136/tailnet/) with **at least one online** Tailscale machine.
    - The Tailscale hostname/IP **must be** referenced via the `ts_dst_host` parameter of the orb's `connect` command.

- You **must** create a [Tailscale auth key](https://tailscale.com/kb/1085/auth-keys/) and store it in an environment variable (either in the [project settings](https://circleci.com/docs/env-vars#setting-an-environment-variable-in-a-project) or in an [organization context](https://circleci.com/docs/env-vars#setting-an-environment-variable-in-a-context)).
    - Be mindful of the [type of auth key](https://tailscale.com/kb/1085/auth-keys/#types-of-auth-keys) you create.
    - By default, the orb's `connect` command expects the Tailscale auth key to be stored in an environment variable named `TS_AUTH_KEY`, however you can opt to store the auth key in a custom-named environment variable; in such case, the environment variable's name **must be** passed to the orb's `connect` command via the `ts_auth_key` parameter.

- If you wish to use the remote Tailscale host as a bastion/jump host:
    - You will need to [start (or restart) Tailscale as a subnet router](https://tailscale.com/kb/1019/subnets/) on that Tailscale host in order to expose the physical subnet route(s) to your target(s).
    - However, the orb won't allow you to use the remote Tailscale host an "exit node". (See "[Caveats & limitations](https://github.com/orbiously/tailscale-orb#caveats--limitations)")

## Features

This orb has 3 commands:
- `install`
- `connect`
- `disconnect`

There are **no job or executor** defined in this orb.

### Commands

The `install` command will:
- Download/Install Tailscale. _(note: if the job uses the Docker executor, this command will also install [tmux](https://github.com/tmux/tmux/wiki))_

The `connect` command will:
- Start Tailscale on the build-host and connect it to your Tailnet.
- Attempt to establish a direct link to the Tailscale machine referenced in the `ts_dst_host` parameter.

The `disconnect` command will:
- Disconnect the build-host from your Tailnet.


## Caveats & limitations

- The [Tailscale "exit node" feature](https://tailscale.com/kb/1103/exit-nodes/) is **not supported**. The reason is that the implementation of a VPN in  CircleCI builds requires to exclude communications between the build-agent (running in the build-host) and other CircleCI components/services from the VPN tunnel. Doing so necessitates a "split-tunnel" approach which is not possible with exit nodes because, [as Tailscale explains](https://tailscale.com/kb/1105/other-vpns/#workaround-split-tunnels):
    > _When using exit nodes, the split-tunnel workarounds will not work, as Tailscale sets its own aggressive firewall rules to route all traffic to your exit node. Exit nodes only support one VPN at a time._

- There are [several types of auth keys](https://tailscale.com/kb/1085/auth-keys/#types-of-auth-keys). Make sure to select the appropriate type(s) when generating the Tailscale auth key you'll be using in your CircleCI builds.

- A Tailscale auth key will automatically [expire after 90 days](https://tailscale.com/kb/1085/auth-keys/#key-expiry).

## Resources

[CircleCI Orb Registry Page](https://circleci.com/orbs/registry/orb/orbiously/tailscale) - The official registry page of this orb for all versions and commands described.

[CircleCI Orb Docs](https://circleci.com/docs/2.0/orb-intro/#section=configuration) - Docs for using, creating, and publishing CircleCI Orbs.

## Important note regarding support

This is an [**uncertified** orb](https://circleci.com/docs/orbs-faq#using-uncertified-orbs); it is **neither tested nor verified by CircleCI**. Therefore CircleCI **will not** be in a position to assist you with using this orb, or troubleshooting /resolving any issues you might encouter while using this orb.

Should you have questions or encounter an issue while using this orb, please:

1. Refer to the "[Caveats & limitations](https://github.com/orbiously/tailscale-orb#caveats--limitations)" section.
2. Check if there is a similar [existing question/issue](https://github.com/orbiously/tailscale-orb/issues). If so, you can add details about your instance of the issue.
3. Visit the [Orb Category of CircleCI Discuss](https://discuss.circleci.com/c/orbs). 
4. If none of the above helps, [open your own issue](https://github.com/orbiously/tailscale-orb/issues/new/choose) with a **detailled** description.

## Contribute

You are more than welcome to contribute to this orb by adding features/improvements or fixing open issues. To do so, please create [pull requests](https://github.com/orbiously/tailscale-orb/pulls) against this repository, and make sure to provide the requested information.
