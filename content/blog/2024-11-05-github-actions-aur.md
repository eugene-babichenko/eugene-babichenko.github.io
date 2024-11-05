+++
title = "Publishing AUR packages from GitHub Actions"
time = 2024-11-05T07:00:00+02:00
[extra]
toc = true
+++

In this post we will discuss automated publishing of updates to AUR packages
from GitHub Actions.

The live and slightly more complicated version of this can be seen at
https://github.com/eugene-babichenko/fixit/blob/master/.github/workflows/release.yml

## Prerequisites

- You already have an AUR repository.
- You are somewhat familiar with GitHub Actions.
- You have a script that generates the `PKGBUILD` file for your releases. Here
  we will refer to it as `./generate-pkgbuild`.
- You tag your releases in the format of `v<version_number>`.

## Setting up SSH keys

It's better to have a separate SSH key for your automation, so let's generate
it:

```bash
ssh-keygen -t ed25519 -f github-aur
```

Now let's add this key to your AUR account. Go to https://aur.archlinux.org/,
log in, click on "My Account" and in "SSH Public Key" add a new line with your
new public key:

```bash
cat github-aur.pub
```

Now we have to deal with the secret key. Go to
`https://github.com/<username>/<repo>/settings/secrets/actions` and add a new
secret named `AUR_SSH_KEY` and paste the contents of our private key here:

```bash
cat github-aur
```

## The scripting

We are going to run our stuff inside an Arch Linux docker container. I'll show
how to set that up later. For now, let's deal with the script.

### Installing dependencies

First, let's install our dependencies (add any other dependencies here as well):

```bash
pacman -Syu --noconfirm
pacman -S --noconfirm openssh git
```

And now some trickery. We would need to use `makepkg` which cannot run under
root. And this is everything the container would provide to us. So let's create
a user first:

### Dealing with users

```bash
useradd -m -G wheel runner
# We need everything to be passwordless
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
```

Now let's transfer the ownership of our files to our new user:

```bash
chown -R runner:runner .
```

From now on everything is going to be run under `su runner -c '...'`.

### SSH configuration

First, install our key into the system:

```bash
mkdir -p ~/.ssh
echo "${{ secrets.AUR_SSH_KEY }}" > ~/.ssh/aur
# Set the correct permissions for the key
chmod 600 ~/.ssh/aur
```

Then, set up the SSH config:

```bash
echo "Host aur.archlinux.org" >> ~/.ssh/config
echo "  IdentityFile ~/.ssh/aur" >> ~/.ssh/config
echo "  User aur" >> ~/.ssh/config
```

And finally, add AUR to `known_hosts`:

```bash
ssh-keyscan -H aur.archlinux.org >> ~/.ssh/known_hosts
```

### Pushing the actual update

Next, clone your AUR repo:

```bash
git clone ssh://aur@aur.archlinux.org/<package_name>.git aur
```

Generate `PKGBUILD`, `.SRCINFO` and test your package:

```bash
# Grab the version number from the git tag
VERSION=${GITHUB_REF#refs/tags/v}
./generate-pkgbuild $VERSION
makepkg --printsrcinfo > .SRCINFO
makepkg
makepkg --install
```

Set up git and push our updated package:

```bash
cp PKGBUILD .SRCINFO aur/
cd aur
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git add PKGBUILD .SRCINFO
git commit -m "release $VERSION"
git push origin master
```

### The final script

```bash
pacman -Syu --noconfirm
pacman -S --noconfirm openssh git

useradd -m -G wheel runner
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

chown -R runner:runner .

su runner -c '
    VERSION=${GITHUB_REF#refs/tags/v}

    mkdir -p ~/.ssh
    echo "${{ secrets.AUR_SSH_KEY }}" > ~/.ssh/aur
    chmod 600 ~/.ssh/aur
    echo "Host aur.archlinux.org" >> ~/.ssh/config
    echo "  IdentityFile ~/.ssh/aur" >> ~/.ssh/config
    echo "  User aur" >> ~/.ssh/config
    ssh-keyscan -H aur.archlinux.org >> ~/.ssh/known_hosts

    git clone ssh://aur@aur.archlinux.org/<your-package>.git aur

    ./generate-pkgbuild $VERSION

    cp PKGBUILD .SRCINFO aur/
    cd aur
    git config user.name "github-actions[bot]"
    git config user.email "github-actions[bot]@users.noreply.github.com"
    git add PKGBUILD .SRCINFO
    git commit -m "release $VERSION"
    git push origin master
'
```

## Setting up the GitHub Action

Create the action that will be triggered by our release tags:

```yaml
name: Release

on:
  push:
    tags:
      - "v*"
```

And add a job that will run all of our scripting inside an Arch Linux container:

```yaml
jobs:
  update-aur:
    name: Update AUR repositories
    runs-on: ubuntu-latest
    container:
      image: archlinux:latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Update AUR
        run: |
          <the above script goes here>
```

And that's it, now you can automatically publish your releases to AUR whenever
you trigger a new GitHub release.
