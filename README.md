# LD25

## Introduction

This is an in-progress entry for the [25th Ludum Dare game jam](http://www.ludumdare.com/). It's based on the theme *You are the Villain*.

![Screenshot](http://i.imgur.com/vgzwH.png)

## Instructions

### Windows

The executable and all of the dependencies should be distributed in a `.zip` archive for you, so you can just extract the archive with your archive manager of choice and run the `.exe`!

### Linux

The executable should be distributed in a `.tar.gz` archive for you.  Depending on your distribution, you may need to install further dependencies by your package manager. The game has been tested on 64-bit ArchLinux and Ubuntu.

#### ArchLinux

`sudo pacman -S love`

#### Ubuntu

```
apt-add-repository ppa:bartbes/love-stable
apt-get update
apt-get install love
```

### Controls

* `left mouse` - clicking on a minion (your evil servants fighting the heroes) will select it
* `w, a, s, d` - four directional movement when a minion is under control
* `space` - attack in the current direction when a minion is under control
* `arrow keys` - move the camera
* `left control` - center the camera on the minion under control

## Contributing

You must follow the code style guidelines:

1. Indent with four spaces
2. Add a new line after each file
3. Use camelBump case
4. Spaces between operators and expressions

## Contributing

### Windows

1. `util/dist.bat` will zip all of the source into a .love file, turn it into an executable and then run it
2. `dist/ld25.exe` will be the distributable executable
3. All DLLs needed when distributing should be in the `deps` directory

### Linux

1. `util/dist.sh` will zip all of the source into a .love file, turn it into an executable and then run it
2. `dist/ld25` will be the distributable executable
3. All shared libraries needed to run, should in most cases, be installed by the package manager and not handled by us
