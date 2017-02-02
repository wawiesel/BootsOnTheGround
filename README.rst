This is BootsOnTheGround [BOTG_]!
=================================

.. image:: https://travis-ci.org/wawiesel/BootsOnTheGround.svg?branch=master
    :target: https://travis-ci.org/wawiesel/BootsOnTheGround

BOTG_ provides a set of FindTPL*.cmake files to find and link Third Party
Libraries (TPLs) to other packages using the CMake_ / TriBITS_ framework
for C/C++/Fortran code.

TPLs
----

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

Take a look at Testing123_ for an example of how to use BOTG_ or further
into the rabbit hole see Template123_ for a simple skeleton project
that uses Testing123_ for unit testing.

How do I use it?
----------------

Bootstrapping is the recommended way of using BOTG (hence the name!). 
You need to do three things to enable BOTG in your TriBITS project.

#. Copy ``cmake/BOTG_INCLUDE.cmake`` to your project. 
#. CMake ``INCLUDE`` the ``cmake/BOTG_INCLUDE.cmake`` first thing in your main ``CMakeLists.txt`` file.
#. Copy ``external/BootsOnTheGround.in`` to your project. 
#. Make sure BOTG comes first in your ``PackagesList.cmake`` file.

.. code-block:: cmake

        TRIBITS_REPOSITORY_DEFINE_PACKAGES(
          BootsOnTheGround external/BootsOnTheGround/src     ST
          ...
        )

Note, if you don't want to clone BOTG to ``external``, then you're going to have to change some stuff in 
``BOTG_INCLUDE.cmake``. See Testing123_ for an example of bootstrapping BOTG.

Then in your ``Dependencies.cmake`` file for any package you can use the
``BOTG_AddTPL()`` macro **after** ``TRIBITS_PACKAGE_DEFINE_DEPENDENCIES``.

.. code-block:: cmake

        TRIBITS_PACKAGE_DEFINE_DEPENDENCIES(
            #do not list TPLs--only packages
        )
        BOTG_AddTPL( LIB REQUIRED Xyz )
        BOTG_AddTPL( TEST REQUIRED Uvw )
        BOTG_AddTPL( LIB OPTIONAL Abc )
        BOTG_AddTPL( TEST OPTIONAL Def )

Note the first argument is ``LIB`` for a main "library" dependency or ``TEST``
for a test-only dependency and the second argument is either ``REQUIRED`` or
``OPTIONAL``. The final is the TPL name from the `TPLs`_ list. See 
`Connection to TriBITS`_ for details.

Downloads
---------

If you won't bootstrap, below are some links to zipped sources you could download and 
unzip into your repository and gain all the benefits of TriBITS and BOTG. 
However, think about using GIT subtrees instead.


**Latest Versions**

[`unstable (develop) <https://github.com/wawiesel/BootsOnTheGround/archive/develop.zip>`_]
[`stable (master) <https://github.com/wawiesel/BootsOnTheGround/archive/master.zip>`_]
[`release (v0.1.0) <https://github.com/wawiesel/BootsOnTheGround/archive/v0.1.0.zip>`_]

**Previous Versions**

[`release (v0.1-beta) <https://github.com/wawiesel/BootsOnTheGround/archive/v0.1-beta.zip>`_]


Principles
----------

- All BOTG TPLs **must** be linkable with ``mkdir build && cd build && cmake ..`` on
  - Windows, Mac, and Linux operating systems with
  - Intel, GNU, and Clang compilers
  and perform correctly. This implies that we need a way to download and install
  packages (we use Hunter_).
- All BOTG TPLs **should** use `semantic versioning <http://semver.org>`_ with the ability
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
    TRIBITS_PACKAGE_DEFINE_DEPENDENCIES(
      LIB_REQUIRED_TPLS
        CURL
        OpenSSL
        ZLib
      TEST_REQUIRED_TPLS
        GTest
    )

With BOTG_, you can use instead a *package* dependency
on ``BootsOnTheGround_CUrl`` available via a simple MACRO
``BOTG_AddTPL``.

.. code-block:: cmake

    TRIBITS_PACKAGE_DEFINE_DEPENDENCIES()
    BOTG_AddTPL( LIB REQUIRED CUrl )
    BOTG_AddTPL( TEST REQUIRED GTest )

Note, the other magic gained by using BOTG is
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

Travis CI
---------

To enable the Travis CI to be able to use curl and https (for Hunter_), I
followed the steps on `Cees-Jan Kiewiet's Blog Post
<https://blog.wyrihaximus.net/2015/09/github-auth-token-on-travis/>`_.

.. _CMake: https://cmake.org/
.. _TriBITS: https://tribits.org
.. _BOTG: http://github.com/wawiesel/BootsOnTheGround
.. _Testing123: http://github.com/wawiesel/Testing123
.. _Template123: http://github.com/wawiesel/Template123
.. _Hunter: http://github.com/ruslo/hunter
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
.. _CUrl: https://curl.haxx.se/libcurl/
.. _HDF5: https://support.hdfgroup.org/HDF5/

