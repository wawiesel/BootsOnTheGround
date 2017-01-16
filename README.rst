This is BootsOnTheGround [BOTG]!

BOTG provides a set of FindTPL*.cmake files to find and link Third Party
Libraries (TPLs) to other packages using the CMake/TriBITS framework.

The goal of BOTG is to provide easy TPL linkages to a set of software
packages which build and operate correctly on Windows, Mac, and Linux.
Currently it provides TPLs for

 - GTest -- Google's unit testing

BOTG integrates with Hunter, a CMake-based package manager, for when the
appropriate TPL cannot be found on the system of interest--it is automatically
downloaded and built with Hunter!

TriBITS is embedded as a subtree with the following command
```
git subtree add --prefix external/TriBITS https://github.com/TriBITSPub/TriBITS.git master --squash
```
