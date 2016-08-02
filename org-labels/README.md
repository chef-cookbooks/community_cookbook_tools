# org-labels

org-labels is a node app that manages Github labels accross entire orgs. It allows you to easily add/remove labels en masse. It also allows you to define your labels in a JSON file that it uses to update all repos with. This makes it easy for us to have consistent labelling on all our orgs, which other tools can consume.

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

Locally the application prompts for username / login. If you receive 404 errors when you run the application open ~/.config/org-labels.json and add a real Github token in place of the generated token. This will get around issues with 2 factor auth.

## Usage

```
org-labels standardize chef-cookbooks chef-cookbooks/community_cookbook_tools
```
