---
layout: post
title: Configuring Git to automatically select personal or job configurations
date: 2020-09-30 21:20:00 +0300
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
is a personal or a job project. Those include settings like `core.editor`, etc.

Then I create two configuration files (I put everything under `~/.config/git` or
`$XDG_CONFIG_HOME/git`):

* `personal.gitconfig` - this is the config to be used with my personal
  projects.

```
[user]
	name = John Doe
	email = john.doe@example.com
	signingkey = DEADBEEF
```

* `job.gitconfig` - this is the config to be used for my main job.

```
[user]
	name = John Doe
	email = john.doe@company.com
	signingkey = AAAAAAAA
```

Then I include both in the main config file (`~/.config/git/config`):

	[includeIf "gitdir:~/Projects/personal/"]
		path = "personal.gitconfig"	

	[includeIf "gitdir:~/Projects/job/"]
		path = "job.gitconfig"

This way appropriate configurations will be applied for projects under
`personal` or `job` subdirectories.
