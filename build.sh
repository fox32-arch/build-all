#!/bin/env sh

###############################################################################
# Changes:                                                                    #
#   v1.0 - 02 Jul 2025 - Avery Rosenblum-O'Connor                             #
#     Description: original version                                           #
#   v1.1 - 04 Nov 2025 - ryfox                                                #
#     Description: correct fox32 capitalization, build fox32os                #
#                                                                             #
# Permission to use, copy, modify, and/or distribute this software for any    #
# purpose with or without fee is hereby granted.                              #
#                                                                             #
# THE SOFTWARE IS PROVIDED “AS IS” AND THE AUTHOR DISCLAIMS ALL WARRANTIES    #
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF            #
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY #
# SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES          #
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN       #
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR  #
# IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.                 #
###############################################################################

start_dir="$(pwd)"
default_build_dir='.'
repo_base_url='https://github.com/fox32-arch'

check_dependencies() {
  for dep in \
    Git:git \
    GCC:gcc \
    Make:make \
    Rust:cargo \
    Lua:lua \
    'SDL2 (with development support)':sdl2-config
  do
    dep_name="$(printf '%s' "$dep" | cut -d : -f 1)"
    dep_cmd="$(printf '%s' "$dep" | cut -d : -f 2)"

    if ! command -v "$dep_cmd" >/dev/null 2>&1
    then
      printf 'Missing system dependency: %s\n' "$dep_name"
      missing_deps=yes
    fi
  done

  case "$missing_deps" in
    'yes')
      exit 1
      ;;
  esac
}

get_base_dir() {
  printf 'Where would you like to build fox32? [default: %s] ' \
    "$default_build_dir"
  read -r build_dir

  case "$build_dir" in
    '')
      build_dir="$default_build_dir"
      ;;
  esac

  mkdir -p "$build_dir" || exit
  cd "$build_dir" || exit
}

clone_repos() {
  for repo in tools fox32 fox32asm fox32rom fox32os
  do
    printf 'Cloning %s... ' "$repo"
    if [ -d "$repo" ]; then
      printf 'already exists, skipping\n'
      continue
    fi
    git clone --quiet --recurse-submodules "$repo_base_url/$repo.git" || exit
    printf 'done\n'
  done
}

# --- build gfx2inc ---

build_gfx2inc() (
  printf 'Building gfx2inc... '
  cd ./tools/gfx2inc || exit
  cargo build --release --quiet || exit
  printf 'done\n'
)

build_fox32asm() (
  printf 'Building fox32asm... '
  cd ./fox32asm || exit
  cargo build --release --quiet || exit
  printf 'done\n'
)

build_fox32dotrom() (
  printf 'Building fox32.rom... '
  cd ./fox32rom || exit
  make --quiet >/dev/null || exit
  cp ./fox32.rom ../fox32/ || exit
  printf 'done\n'
)

build_fox32() (
  printf 'Building fox32... '
  cd ./fox32 || exit
  make --quiet || exit
  printf 'done\n'
)

build_fox32osdotimg() (
  printf 'Building fox32os.img... '
  cd ./fox32os || exit
  make --quiet >/dev/null || exit
  printf 'done\n'
)

build_all() {
  build_gfx2inc || exit
  build_fox32asm || exit
  build_fox32dotrom || exit
  build_fox32 || exit
  build_fox32osdotimg || exit
}

finish() {
  printf 'fox32 built at: ./%s\n' "$(realpath --relative-to="$start_dir" ./fox32/fox32)"
  printf 'Run it now? [Y/n] '
  read -r runnow

  case "$runnow" in
    'n' | 'no')
      exit 0
      ;;
  esac

  ./fox32/fox32 --disk ./fox32os/fox32os.img >/dev/null 2>&1 &
}

print_sep() {
  sep='================================================================================'

  printf '%s\n' "$sep"
}

main() {
  check_dependencies || exit
  get_base_dir || exit
  print_sep
  clone_repos || exit
  print_sep
  build_all || exit
  print_sep
  finish || exit
}

main
