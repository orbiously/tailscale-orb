# Tailscale Orb


[![CircleCI Build Status](https://circleci.com/gh/orbiously/tailscale-orb.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/orbiously/tailscale-orb) [![CircleCI Orb Version](https://badges.circleci.com/orbs/orbiously/tailscale.svg)](https://circleci.com/orbs/registry/orb/orbiously/tailscale) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/orbiously/tailscale-orb/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)



This orb will allow users to connect the build host to a [Tailscale Tailnet](https://tailscale.com/kb/1151/what-is-tailscale/). The build host will then be able to communicate _privately_ with any Tailscale host in the same Tailnet via a peer-to-peer mesh network.

You can then also use the remote Tailscale host as a bastion/jump host.

**This is an “executor-agnostic” orb; there is only one set of commands which can be used on any executor. The orb’s underlying code handles the OS/platform detection, and runs the appropriate OS-specific bash commands.**

---

## Requirements

- You need to have an existing [Tailnet](https://tailscale.com/kb/1136/tailnet/) with at least 1 **online** Tailscale machine
- You **must** create a [Tailscale auth key](https://tailscale.com/kb/1085/auth-keys/) and store it in an environment variable (either in the [project settings](https://circleci.com/docs/env-vars#setting-an-environment-variable-in-a-project) or in an [organization context](https://circleci.com/docs/env-vars#setting-an-environment-variable-in-a-context)).
_By default, the orb's `connect` command expects the Tailscale auth key to be stored in an environment variable named `TS_AUTH_KEY`, however you can opt to store the auth key in a custom-named environment variable; in such case, the environment variable's name **must be** passed to the orb's `connect` command via the `s-auth-key` parameter._
- If you wish to use one of the remote Tailscale host as a bastion/jump host, you will need to 

## Caveats & limitations

## Resources

[CircleCI Orb Registry Page](https://circleci.com/orbs/registry/orb/orbiously/tailscale) - The official registry page of this orb for all versions and commands described.

[CircleCI Orb Docs](https://circleci.com/docs/2.0/orb-intro/#section=configuration) - Docs for using, creating, and publishing CircleCI Orbs.

### Important note regarding support

This is an [**uncertified** orb](https://circleci.com/docs/orbs-faq#using-uncertified-orbs); it is **neither tested nor verified by CircleCI**. Therefore CircleCI **will not** be in a position to assist you with using this orb, troubleshooting /resolving any issues you might encouter while using this orb.

Should you have questions or trouble using the orb, please:

1. Refer to the "Caveats & limitations" section
2. Check if there is a similar [existing question/issue](https://github.com/orbiously/tailscale-orb/issues). If so, you can add details about your instance of the issue.
3. Visit the [Orb Category of CircleCI Discuss](https://discuss.circleci.com/c/orbs). 
4. If none of the above helps, [open your own issue](https://github.com/orbiously/tailscale-orb/issues/new/choose) with a **detailled** description

### Contribute

You are more than welcome to contribute to this orb by adding features/improvements or fixing open issues. To do so, please create [pull requests](https://github.com/orbiously/tailscale-orb/pulls) against this repository, and make sure to provide the requested information.


### How to Publish An Update
1. Merge pull requests with desired changes to the main branch.
    - For the best experience, squash-and-merge and use [Conventional Commit Messages](https://conventionalcommits.org/).
2. Find the current version of the orb.
    - You can run `circleci orb info orbiously/tailscale | grep "Latest"` to see the current version.
3. Create a [new Release](https://github.com/orbiously/tailscale-orb/releases/new) on GitHub.
    - Click "Choose a tag" and _create_ a new [semantically versioned](http://semver.org/) tag. (ex: v1.0.0)
      - We will have an opportunity to change this before we publish if needed after the next step.
4.  Click _"+ Auto-generate release notes"_.
    - This will create a summary of all of the merged pull requests since the previous release.
    - If you have used _[Conventional Commit Messages](https://conventionalcommits.org/)_ it will be easy to determine what types of changes were made, allowing you to ensure the correct version tag is being published.
5. Now ensure the version tag selected is semantically accurate based on the changes included.
6. Click _"Publish Release"_.
    - This will push a new tag and trigger your publishing pipeline on CircleCI.
