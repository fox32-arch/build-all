# fox32 Quick Build Script

This shell script will clone and build everything necessary to run fox32os, using the following steps:
- Check for required build dependencies: Git, Make, GCC, Rust, Lua, and SDL2
- Clone the following repositories: `fox32`, `fox32asm`, `fox32rom`, `fox32os`, and `tools`
- Build all utilities, ROM, OS, and emulator
- Optionally run the emulator

After reviewing [build.sh](build.sh) to understand what it does, you may run `sh <(curl -sSL https://github.com/fox32-arch/build-all/raw/refs/heads/main/build.sh)` to start the build process.
Alternatively, you may clone this repository or download build.sh separately.
The script will ask you where you want to place the fox32 repositories before building.

## License
This build script is licensed under the [0BSD license](LICENSE).
