This is BootsOnTheGround [BOTG_]!
=================================

.. image:: https://travis-ci.org/wawiesel/BootsOnTheGround.svg?branch=master
    :target: https://travis-ci.org/wawiesel/BootsOnTheGround

BOTG_ provides a set of FindTPL*.cmake files to find and link Third Party
Libraries (TPLs) to other packages using the CMake / TriBITS_ framework
for C/C++/Fortran code.

Currently we have the following TPLs wrapped up nice and purdy:

- BoostFilesystem_ -- Cross-platform file system queries [C++]
- CUrl_ -- push and pull across the web [C++]
- Fmt_ -- amazing sprintf, printf replacement [C++]
- GFlags_ -- command line flags parsing [C++]
- GTest_ -- Google's unit testing system [C++]
- HDF5_ -- hierarchical binary data containers [C++]
- NLJson_ -- NLohmann's JSON as a first-class citizen [C++]
- OpenSSL_ -- hash for security [C++]
- SZip_ -- scientific zip algorithm [C++]
- Spdlog_ -- fast, versatile logging [C++]
- ZLib_ -- compession/decompression algorithm [C++]

Downloads
---------

Below are some links to  and unzip one of the following sources directly to your
TriBITS_ repository, perhaps to ``external/BootsOnTheGround``, we **strongly
encourage** using GIT subtrees instead, linking directly to a particular version tag or the master
branch of the repo.

**Latest Versions**

[`unstable (develop) <https://github.com/wawiesel/BootsOnTheGround/archive/develop.zip>`_]
[`stable (master) <https://github.com/wawiesel/BootsOnTheGround/archive/master.zip>`_]
[`release (v0.1.0) <https://github.com/wawiesel/BootsOnTheGround/archive/v0.1.0.zip>`_]

**Previous Versions**

[`release (v0.1-beta) <https://github.com/wawiesel/BootsOnTheGround/archive/v0.1-beta.zip>`_]


Principles
----------

- All TPLs must be linkable with ``mkdir build && cd build && cmake ..`` on
  - Windows, Mac, and Linux operating systems with
  - Intel, GNU, and Clang compilers
  and perform correctly. This implies that we need a way to download and install
  packages (we use Hunter_).
- All TPLS must have permissible,
  `non-copyleft licenses <http://fosslawyers.org/permissive-foss-licenses-bsd-apache-mit>`_.
  We need these TPLs in our open source TriBITS_ projects, but also in special,
  export-controlled nuclear reactor simulations like CASL_.
- All TPLs should use `semantic versioning <http://semver.org>`_ with the ability
  to link to a particular version, either ``MAJOR.MINOR`` or ``MAJOR`` (in which case
  the latest ``MINOR`` is chosen).

Connection to TriBITS
---------------------

TriBITS_ does all the heavy lifting of package dependency management,
however, it has some limitations in dealing with TPLs. One TPL cannot
be dependent on another TPL, and TPLs cannot have versions. The idea
is that we wrap each TPL in a TriBITS *package*, which does provide
this capability.

Say you needed TPL ``CURL`` for your library and ``GTest`` for testing.
``CURL`` requires ``OpenSSL`` and ``ZLib``. In every TriBITS
cmake/Dependencies.cmake file, you would need to specify:

.. code-block:: cmake

    SET(LIB_REQUIRED_DEP_PACKAGES)
    SET(TEST_REQUIRED_DEP_PACKAGES)
    SET(LIB_REQUIRED_DEP_TPLS CURL OpenSSL ZLib)
    SET(TEST_REQUIRED_DEP_TPLS GTest)

With BOTG_, you can use instead a *package* dependency
called ``BootsOnTheGround_CURL`` and it will handle linking
in dependent TPLs automatically.

.. code-block:: cmake

    SET(LIB_REQUIRED_DEP_PACKAGES BootsOnTheGround_CURL)
    SET(TEST_REQUIRED_DEP_PACKAGES BootsOnTheGround_GTest)
    SET(LIB_REQUIRED_DEP_TPLS)
    SET(TEST_REQUIRED_DEP_TPLS)

Note, the other magic gained by using ``BootsOnTheGround_CURL`` is
that Hunter_ is used to download, build, and install any TPLs it
cannot find!

Connection to Hunter
--------------------

BOTG_ should find local libraries on your machine that meet the version
requirements. However, when it does not, BOTG uses Hunter_, a CMake-based
package manager. We looked at using `spack<https://spack.io/>`_ but it is
not clear if they will ever have Windows support.

-----------------------------------------------------------------------------

To Do
-----
- Enable version specification and process TPL version information. Should
  be able to print a summary of the linked TPLs.
- Enable windows testing.
- Complete RST documentation of the BOTG functions and the framework itself.
- Add SuperLU.
- Handle linking flags better for different compilers/operating systems.

Repository Structure
--------------------

This repository uses
`Gitflow <https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow/>`_,
i.e.

#. Development is **feature-based**, always on ``feature/X`` branches of ``develop``.
   The ``develop`` branch can be unstable.
#. The ``master`` branch is only updated from ``develop`` when all tests pass.
   The ``master`` branch is always **stable**.
#. Releases are first created as a release branch, ``release/vMAJOR.MINOR``, then when
   ready are merged into the ``master`` branch and tagged ``vMAJOR.MINOR.0``.
#. Hotfixes are created as a branch off ``master``: ``hotfix/vMAJOR.MINOR.PATCH``,
   when finished are merged into ``master`` and tagged ``vMAJOR.MINOR.PATCH``,
   then merged into ``develop``.

Tricky Details
--------------
TriBITS_ is embedded as a subtree with the following command

::

    git subtree add --prefix external/TriBITS
        https://github.com/TriBITSPub/TriBITS.git
        master --squash

To enable the Travis CI to be able to use curl and https (for Hunter_), I
followed the steps on `Cees-Jan Kiewiet's Blog Post
<https://blog.wyrihaximus.net/2015/09/github-auth-token-on-travis/>`_.

.. _Hunter: http://github.com/ruslo/hunter
.. _TriBITS: https://tribits.org
.. _BOTG: http://github.com/wawiesel/BootsOnTheGround
.. _GTest: http://github.com/google/googletest
.. _GFlags: https://gflags.github.io/gflags
.. _BoostFilesystem: http://www.boost.org/doc/libs/1_63_0/libs/filesystem/doc/reference.html
.. _Fmt: http://fmtlib.net/latest/index.html
.. _Spdlog: https://github.com/gabime/spdlog/wiki/1.-QuickStart
.. _SZip: http://www.compressconsult.com/szip
.. _ZLib: http://www.zlib.net/
.. _NLJson: https://github.com/nlohmann/json#examples
.. _CASL: http://www.casl.gov
.. _OpenSSL: https://www.openssl.org/

