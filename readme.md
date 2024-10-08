# Chases and Stills

A small game inspired by GCE's *Mine Storm*. I'm not going to say it's amazing, but it's my first complete, independent programming project, and I'm rather happy with it.

The controls are arrow keys and 'z'. One can press 'f' to fullscreen. In the spirit of Second Generation video games, I made frequent use of tiny integers with no overflow prevention, so there may be crashes and unintended behavior. In my testing, there are 256 levels excluding the first that loop endlessly. The Player originally had only three lives, but I found it more fun to keep trying continuously, so I increased the number to 100. The game closes when lives are exhausted.

## Building

This project requires Zig. At the time of writing, building was tested with Zig 0.13.0, but past or future versions may work. To build, execute `zig build -Doptimize=ReleaseFast`. To run, execute the generated executable binary or execute `zig build -Doptimize=ReleaseFast run`.

One may need to update the hash for raylib-zig. To do this, execute `zig fetch --save https://github.com/Not-Nik/raylib-zig/archive/devel.tar.gz`.

## Repositories

*Chases and Stills* can be found on GitHub and IPFS. GitHub should always work, but I am personally publishing the repository on IPFS, so it may not always be available there.

GitHub: [https://github.com/SinjurJ/chases-and-stills](https://github.com/SinjurJ/chases-and-stills)  
IPFS: [ipns://k51qzi5uqu5dh6ombngx7bhdw9ivzioibwig5qdqzpabl3xmm3h61nnre2arfy](ipns://k51qzi5uqu5dh6ombngx7bhdw9ivzioibwig5qdqzpabl3xmm3h61nnre2arfy)

## Copyright

*Chases and Stills* was designed and written by Jareth McGhee. This project, associated code, and associated files are licensed [MIT](https://opensource.org/license/mit). There are no graphical or auditory assets, but one can consider the output of the program, including the designs of the Mines and of the Player, to be dedicated to the public domain with [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) and/or any later version. Copies of relevant third party licenses are included.
