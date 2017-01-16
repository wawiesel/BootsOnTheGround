This is BootsOnTheGround [BOTG_]!
=================================

BOTG_ provides a set of FindTPL*.cmake files to find and link Third Party
Libraries (TPLs) to other packages using the CMake/TriBITS_ framework.

The goal of BOTG is to provide easy TPL linkages to a set of software
packages which build and operate correctly on Windows, Mac, and Linux.
Currently it provides TPLs for

- GTest_ -- Google's C++ unit testing system

BOTG uses Hunter_, a CMake-based package manager, for when the
appropriate TPL cannot be found on the system of interest--it is automatically
downloaded and built with Hunter!

TriBITS
-------

TriBITS_ is embedded as a subtree with the following command

::

    git subtree add --prefix external/TriBITS https://github.com/TriBITSPub/TriBITS.git master --squash

.. _Hunter: http://github.com/ruslo/hunter
.. _BOTG: http://github.com/wawiesel/BootsOnTheGround
.. _GTest: http://github.com/google/googletest
