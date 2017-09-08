# org-labels

org-labels is a node app that manages Github labels across entire orgs. It allows you to easily add/remove labels en masse. It also allows you to define your labels in a JSON file that it uses to update all repos with. This makes it easy for us to have consistent labelling on all our orgs, which other tools can consume.

## Homepage

<https://github.com/repo-utils/org-labels>

## Installation

First you'll need node on your system. If you're running OS X you can install it via brew with

```
brew install nodejs
```

Once you have node installed you can install org-labels

```
npm install -g org-labels
```

## Configuration

A configuration JSON file is located at config/github_labels.json

Locally the application prompts for username / login.

If you receive 404 errors when you run the application either:

* open ~/.config/org-labels.json and add a Github token that has the appropriate privileges in place of the generated token. This will get around issues with 2 factor auth.

* open <https://github.com/settings/tokens> and edit the token to have the appropriate privileges. The token will look something like `org-labels CLI tool (2017-09-07T23:36:35.718Z)`.

Example of a 404 error indicating the token has insufficient privileges:

```
Jennifers-MBP:community_cookbook_tools sigje$ org-labels standardize chef-cookbooks chef-cookbooks/community_cookbook_tools
GitHub rate limit remaining: 4830
found 144 repositories in chef-cookbooks

checking 15 labels across 144 repos
Error: 404 - https://api.github.com/repos/chef-cookbooks/vcruntime/labels
```

Example of successful usage (output edited for length):

```
Jennifers-MBP:community_cookbook_tools sigje$ org-labels standardize chef-cookbooks chef-cookbooks/community_cookbook_tools
GitHub rate limit remaining: 4641
found 144 repositories in chef-cookbooks

checking 15 labels across 144 repos
...
label `Type: Feature Request` successfully created at /repos/chef-cookbooks/elixir/labels
label `Type: Question` successfully created at /repos/chef-cookbooks/elixir/labels
label `Type: Enhancement` successfully created at /repos/chef-cookbooks/elixir/labels
label `Type: Maintenance` successfully created at /repos/chef-cookbooks/elixir/labels
label `Type: Bug` successfully created at /repos/chef-cookbooks/elixir/labels
label `Priority: Critical` successfully created at /repos/chef-cookbooks/elixir/labels
label `Priority: High` successfully created at /repos/chef-cookbooks/elixir/labels
label `Priority: Medium` successfully created at /repos/chef-cookbooks/elixir/labels
label `Priority: Low` successfully created at /repos/chef-cookbooks/elixir/labels
label `Status: Pending Contributor Response` successfully created at /repos/chef-cookbooks/elixir/labels
label `Status: Maintainer Review Needed` successfully created at /repos/chef-cookbooks/elixir/labels
label `Status: On Hold` successfully created at /repos/chef-cookbooks/elixir/labels
label `Status: In Progress` successfully created at /repos/chef-cookbooks/elixir/labels
label `Status: Blocked` successfully created at /repos/chef-cookbooks/elixir/labels
label `Status: Abandoned` successfully created at /repos/chef-cookbooks/elixir/labels
...
119 label updates across 10 repos
done standardizing labels

```

## Usage

The following command standardizes labels in all `chef-cookbooks` repos using the [configuration](https://github.com/chef-cookbooks/community_cookbook_tools/blob/master/config/github_labels.json) found in the `chef-cookbooks/community_cookbook_tools` repo. 

```
org-labels standardize chef-cookbooks chef-cookbooks/community_cookbook_tools
```
