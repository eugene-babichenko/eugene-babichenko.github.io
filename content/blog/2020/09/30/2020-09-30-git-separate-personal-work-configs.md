---
layout: post
title: Configuring Git to automatically select personal or job configurations
date: 2020-09-30 21:20:00+03:00
last_modified_at: 2022-02-12 15:40:00+02:00
categories: git
---

Making per-repository git configurations for personal and job repositories is a
bit annoying so here is a simple approach for automatically applying different
Git configurations to different repositories.

First, you need to keep your personal and job repositories under different
directories. In my case I do the following:

	~/Projects
	├── job
	└── personal

After that, you need to separate your configurations which is easy thanks to
Git `includeIf` feature. In the first-level config (`~/.config/git/config` or
`~/.gitconfig`) I store settings that should be applied regardless of whether it
is a personal or a job project (e.g. settings like `core.editor`, etc) **and**
the default configuration with my personal email and PGP key.

Then I create separate configuration files for non-default configurations (I put
everything under `~/.config/git` or `$XDG_CONFIG_HOME/git`):

* `job.gitconfig` - this is the config to be used for my main job.

	[user]
		name = John Doe
		email = john.doe@company.com
		signingkey = AAAAAAAA

Then I include this file in the main config file (`~/.config/git/config`):

	[user]
		name = John Doe
		email = john.doe@example.com
		signingkey = DEADBEEF

	[includeIf "gitdir:~/Projects/job/"]
		path = "job.gitconfig"

This way appropriate configurations will be applied for projects under
`personal` (and everything else other than `job`) or `job` subdirectories.

**[UPD 2022-02-12]:** Now I use separate files only for job directories related
configurations and use the default configuration for everything else putting it
into the top-level file.
