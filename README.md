# MacBrowser

A premium macOS browser prototype built in C++/Objective-C++ using Cocoa and WebKit.

## Features

- Dark, restrained UI inspired by premium design principles
- Home, Back, Forward, Reload controls
- Address bar with URL entry and validation
- Built-in styled home page that reflects a polished visual aesthetic
- WebKit rendering with JavaScript enabled

## Requirements

- macOS with Xcode developer tools
- `clang++` / `clang` with Objective-C++ support

## Build

```bash
./scripts/build.sh
```

## Run

```bash
./MacBrowser
```

## Project structure

- `src/main.mm` — application entry point
- `src/BrowserApp.h` — application class declaration
- `src/BrowserApp.mm` — native UI and WebKit integration
- `CMakeLists.txt` — optional CMake build script
- `.gitignore` — ignored files for macOS, CMake, Python, and editor files
- `LICENSE` — MIT license
- `scripts/build.sh` — convenience build script

## GitHub repository setup

1. Create a new repository on GitHub.
2. Name it `macbrowser` or `mac-browser`.
3. Push this project as the first commit.
4. Add a repository description like: "Premium macOS browser prototype using Objective-C++ and WebKit."

## New account setup

If you need a fresh GitHub account for this project:

1. Go to https://github.com/join
2. Choose a username related to your browser project.
3. Use a secure password and a recovery email.
4. Verify your account via email and enable 2FA if possible.
5. Create a new repository and push the project.

## Notes

This project is a native macOS browser prototype designed for a premium visual experience. Use it as a foundation for adding tabs, bookmarks, history, and keyboard shortcuts.
