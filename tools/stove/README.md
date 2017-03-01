# Stove

See <https://github.com/chef-cookbooks/community_cookbook_documentation/blob/master/RELEASE_PROCESS.MD#use-stove-for-tag-management--file-pruning> for our thoughts on using stove to release cookbooks

## Homepage

<https://github.com/sethvargo/stove>

## Installation

```
chef gem install stove
```

or

```
gem install stove
```

## Configuration

See the sample .stove file in this directory

## Usage

From the cookbook directory simple run `stove` to tag the cookbook and push it to the Supermarket. If you accidentally push a cookbook that you're not authorized to push you'll need to add yourself on Supermarket and then run `stove --no-git` to skip the git tagging. If you are uploading a Chef 12+ cookbook you can use the `--extended-metadata` option to upload issues_url and source_url metadata
