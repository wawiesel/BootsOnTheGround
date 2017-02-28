This is BootsOnTheGround [BOTG_]! |build|
=========================================

.. |build| image:: https://travis-ci.org/wawiesel/BootsOnTheGround.svg?branch=master
    :target: https://travis-ci.org/wawiesel/BootsOnTheGround

CMake/TriBITS third-party-library linker for C++/Fortran

.. image:: https://c1.staticflickr.com/3/2860/33135230166_b7890b6015_b.jpg

BOTG_ provides a set of FindTPL*.cmake files to find and link Third Party
Libraries (TPLs) to other packages using the CMake_ / TriBITS_ framework
for C/C++/Fortran code.

.. code-block:: cmake

    TRIBITS_PACKAGE( MyPackage )
    TRIBITS_PACKAGE_DEFINE_DEPENDENCIES(
        LIB_REQUIRED_PACKAGES TheirPackage
    ) 
    botgAddTPL( LIB OPTIONAL CURL )    #Optional for building
    botgAddTPL( TEST REQUIRED GTEST )  #Required only for tests
    TRIBITS_PACKAGE_POSTPROCESS()

The available ``XXX`` allowed in ``botgAddTPL( LIB|TEST OPTIONAL|REQUIRED XXX)``
are listed below.

Current TPLs
------------

Currently we have the following TPLs wrapped up nice and purdy:

- BOOST_FILESYSTEM_ - Cross-platform file system queries [C++]
- CURL_ - push and pull across the web [C++]
- FMT_ - amazing sprintf, printf replacement [C++]
- GFLAGS_ - command line flags parsing [C++]
- GTEST_ - Google's unit testing system [C++]
- HDF5_ - hierarchical binary data containers [C++]
- NLJSON_ - NLohmann's JSON as a first-class citizen [C++]
- OPENSSL_ - hash for security [C++]
- SZIP_ - scientific zip algorithm [C++]
- SPDLOG_ - fast, versatile logging [C++]
- ZLIB_ - compession/decompression algorithm [C++]

Take a look at Testing123_ for an example of how to use BOTG_.

How do I use it?
----------------

Bootstrapping is the recommended way of using BOTG (hence the name!). 
You need to do four things to enable BOTG in your TriBITS C/C++/Fortran project.

#. Copy ``cmake/BOTG_INCLUDE.cmake`` containing bootstrap commands to your project's root ``cmake`` directory. 
#. Copy ``external/BootsOnTheGround.in`` containing repo link commands to your project's ``external`` directory. 
#. ``INCLUDE(cmake/BOTG_INCLUDE.cmake)`` first thing in your root ``CMakeLists.txt`` file to execute the bootstrap.
#. Add BOTG to your TriBITS ``PackagesList.cmake`` file.

.. code-block:: cmake

        TRIBITS_REPOSITORY_DEFINE_PACKAGES(
          BootsOnTheGround external/BootsOnTheGround/src     ST
          ...
        )

Note, if you don't want to bootstrap BOTG to the directory ``external``, then you're going to have to change the line in 
``BOTG_INCLUDE.cmake`` that references ``external/BootsOnTheGround.in`` . See Testing123_ for an example of bootstrapping BOTG.

Then in your ``Dependencies.cmake`` file for any package you can use the
``botgAddTPL()`` macro **after** ``TRIBITS_PACKAGE_DEFINE_DEPENDENCIES``.

.. code-block:: cmake

        TRIBITS_PACKAGE_DEFINE_DEPENDENCIES(
            #do not list TPLs--only packages
        )
        botgAddTPL( LIB REQUIRED XYZ )
        botgAddTPL( TEST REQUIRED UVW )
        botgAddTPL( LIB OPTIONAL ABC )
        botgAddTPL( TEST OPTIONAL DEF )

Note the first argument is ``LIB`` for a main "library" dependency or ``TEST``
for a test-only dependency and the second argument is either ``REQUIRED`` or
``OPTIONAL``. The final is the TPL name from the `TPLs`_ list. See 
`Connection to TriBITS`_ for details. It is always upper case, with "_" used
to separate words.

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

Say you needed TPL ``CURL`` for your library and ``GTEST`` for testing.
``CURL`` requires ``OPENSSL`` and ``ZLIB``. In every TriBITS
cmake/Dependencies.cmake file, you would need to specify:

.. code-block:: cmake
    TRIBITS_PACKAGE_DEFINE_DEPENDENCIES(
      LIB_REQUIRED_TPLS
        CURL
        OPENSSL
        ZLIB
      TEST_REQUIRED_TPLS
        GTEST
    )

With BOTG_, you can use instead a *package* dependency
on ``BootsOnTheGround_CURL`` available via a simple MACRO
``botgAddTPL``.

.. code-block:: cmake

    TRIBITS_PACKAGE_DEFINE_DEPENDENCIES()
    botgAddTPL( LIB REQUIRED CURL )
    botgAddTPL( TEST REQUIRED GTEST )

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
.. _Hunter: http://github.com/ruslo/hunter

.. _GTEST: http://github.com/google/googletest
.. _GFLAGS: https://gflags.github.io/gflags
.. _BOOST_FILESYSTEM: http://www.boost.org/doc/libs/1_63_0/libs/filesystem/doc/reference.html
.. _FMT: http://fmtlib.net/latest/index.html
.. _SPDLOG: https://github.com/gabime/spdlog/wiki/1.-QuickStart
.. _SZIP: http://www.compressconsult.com/szip
.. _ZLIB: http://www.zlib.net/
.. _NLJSON: https://github.com/nlohmann/json#examples
.. _CASL: http://www.casl.gov
.. _OPENSSL: https://www.openssl.org/
.. _CURL: https://curl.haxx.se/libcurl/
.. _HDF5: https://support.hdfgroup.org/HDF5/

