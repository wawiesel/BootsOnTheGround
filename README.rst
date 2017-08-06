This is BootsOnTheGround [BOTG_]! |build|
=========================================

.. |build| image:: https://travis-ci.org/wawiesel/BootsOnTheGround.svg?branch=master
    :target: https://travis-ci.org/wawiesel/BootsOnTheGround

CMake macros for easy projects with TPLS C/C++/Fortran

.. image:: https://c1.staticflickr.com/3/2860/33135230166_b7890b6015_b.jpg

BOTG_ provides macros for easy project/package setup and a set
of FindTPL*.cmake files to find and link Third Party Libraries (TPLs)
to other packages using the CMake_ / TriBITS_ framework for C/C++/Fortran code.

.. code-block:: cmake

    #Inside MyPackage/cmake/Dependencies.cmake
    botgPackageDependencies(
        LIB_REQUIRED_PACKAGES
            TheirPackage
            BootsOnTheGround_CURL
        TEST_REQUIRED_PACKAGES
            BootsOnTheGround_GTEST
    )

In order to use this command, you need to add BootsOnTheGround as a package
to your ``PackagesList.cmake`` file in your project. The amazing thing about
the ``BootsOnTheGround_XXX`` dependencies are that they unify the normal way
of finding a TPL on your system with the Hunter_ system for downloading and
building TPLS on the fly!

The available ``XXX`` allowed are listed below.

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
- BLAS_ - basic linear algebra subprograms [Fortran]
- CBLAS_ - C bindings for BLAS_ [C/C++]
- LAPACK_ - linear algebra package [Fortran]

Once the interface of BOTG crystalizes, the only changes will be adding new TPLS,
and adding versioning support for finding those TPLS.

BOTG Macros
-----------

BOTG provides a small set of macros for building projects from a pool of packages,
*eventually* with support for package versioning. These macros are
all contained in the ``BOTG.cmake`` file which can be bootstrapped into any
project build.

- ``botgProject()`` - declare a project (inside root CMakeLists.txt)
- ``botgPackage( name )`` - declare a package (inside subdir CMakeLists.txt)
- ``botgSuperPackage( name )`` - declare a super package (i.e. package with subpackages)
- ``botgEnd()`` - wrap-up processing a Project or Package
- ``botgAddCompilerFlags( lang compiler os flags )`` - add compiler flags only for a particular language/compiler/os combination
- ``botgAddLinkerFlags( compiler os flags )`` - add linker flags only for a particular compiler/os combination
- ``botgLibrary( name ... )`` - declare and define a library using current compiler and linker flags
- ``botgTestDir( dir )`` - declare a unit test directory
- ``botgPackagesList( ... )`` - declare the packages and subdirs in a project (inside ``PackagesList.cmake``)
- ``botgSuperPackageContents( ... )`` - declare the packages and subdirs in a super package 
    (inside ``cmake/Dependencies.cmake`` for a package
- ``botgTPLsList( ... )`` - declare the TPLs and ``findTPL*.cmake`` locations (inside ``TPLsList.cmake``)
- ``botgPackageDependencies( ... )`` - declare the dependencies of a package
- ``botgDownloadExternalProjects( ... )`` - download an external project at configure time (used to bootstrap BootsOnTheGround)

Take a look at Testing123_ for an example of how to use BOTG_.

How do I get started?
---------------------

Bootstrapping is the recommended way of using BOTG (hence the name!).
You need to do four things to enable BOTG in your TriBITS C/C++/Fortran project.

#. Copy ``cmake/BOTG_INCLUDE.cmake`` containing bootstrap commands to your project's root ``cmake`` directory.
#. Copy ``external/BootsOnTheGround.in`` containing repo link commands to your project's ``external`` directory.
#. ``INCLUDE(cmake/BOTG_INCLUDE.cmake)`` first thing in your root ``CMakeLists.txt`` file to execute the bootstrap.
#. Add BOTG to your TriBITS ``PackagesList.cmake`` file.

.. code-block:: cmake

        botgProjectContents(
            BootsOnTheGround external/BootsOnTheGround/src     ST
            ...
        )

Note, if you don't want to bootstrap BOTG to the directory ``external``, then
you're going to have to change the line in ``BOTG_INCLUDE.cmake`` that
references ``external/BootsOnTheGround.in`` . See Testing123_ for an example
of bootstrapping BOTG.

Then in your ``Dependencies.cmake`` file for any package you can use the
``botgPackageDependencies()`` macro.

.. code-block:: cmake

        botgPackageDependencies(
            LIB_REQUIRED_PACKAGES
               BootsOnTheGround_SPDLOG
            TEST_REQUIRED_PACKAGES
               BootsOnTheGround_GTEST
        )

Note that we are now linking to *packages* instead of *TPLS* through BOTG_.
Behind the scenes, the ``botgPackageDependencies`` macro adds the relevant actual TPL
links and calls ``TRIBITS_PACKAGE_DEFINE_DEPENDENCIES``.


Why?
----

Every software package needs to answer the question of why does it exist.
This package could be seen as another layer on top of an already precarious
cake (CMake bottom layer, TriBITS middle layer). And there is a really good reason
*not* to create another CMake macro system, namely maintainability. CMake is a
popular solution to a persistent problem (cross-platform C++ builds), which means there
are many people out there who pick up CMake as a skill. But how many people
know your macros? So you limit who can help with what we believe is the worst
part of software development: configuration.

But we did it anyway!? We did it because we are targeting people without any
CMake skill. These are generally scientists and engineers who:

#. do not have a dedicated build guy,
#. do not have time or want CMake as a skill,
#. use or depend on a mix of C++ and Fortran,
#. are using TriBITS_ anyway, and/or
#. who hate writing configuration code.

For these people, the goal are simple.

Create and deploy software that solves a new *scientific* problem--*NOT*
a software engineering one. So our (yes, we are those guys) requirements are
something like:

#. easily use existing TPLs with versioning,
#. easily use each other's packages with versioning, and
#. easily manage combinations of Fortran, C, and C++ code.

Yes *easy* is the key word. The versioning part is also important because we
need reproducability. Once we are combining these various packages in new and
interesting ways, knowing exactly what we have at any given time is really
important.

So we've mentioned TriBITS_ and there is a section describing the role of
TriBITS. But TriBITS does not really handle versioning of TPLS and packages,
which we need. It also does not intend to provide a set of standard
FindTPL*.cmake files, which we think needs to exist. (That's where this
project started. :)) Finally, TriBITS is still a little tricky to use, and
results in a decent amount of boilerplate and a mix of TriBITS and CMake
where it's a little difficult to see exactly what's going on. The BOTG
interface to define the software package is very simple. We don't really see
it changing. As TriBITS and CMake evolve, the best practices that are used
under the hood for defining the libraries and executables may change, but
the interface is straightforward:

#. Define a project as a collection of external and internal packages.
#. Define for each internal package:

   #. dependency on external packages and TPLs;
   #. headers, libraries, and executables to deploy;
   #. unit tests; and the minimal
   #. compiler/linker flags or C++ standard *needed* to build.


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

With BOTG_, you can use instead a *package* dependencies. This will give us
much more fine grain control over meeting requirements like specific versions.

.. code-block:: cmake

    botgPackageDependencies(
        LIB_REQUIRED_PACKAGES
            BootsOnTheGround_CURL
        TEST_REQUIRED_PACKAGES
            BootsOnTheGround_GTEST
    )

Note, the other magic gained by using BOTG is that Hunter_ is used to download,
build, and install any TPLs it cannot find!

Connection to Hunter
--------------------

BOTG_ should find local libraries on your machine that meet the version
requirements. However, when it does not, BOTG uses Hunter_, a CMake-based
package manager. We looked at using `spack<https://spack.io/>`_ but it is
not clear if they will ever have Windows support.

Some Principles
---------------

- If your project has much more than ``100 + number of source files`` lines of
  CMake, you're doing it wrong.
- Every project should build and pass all tests with a simple
  ``mkdir build && cd build && cmake .. && make && ctest`` on
  - Windows, Mac, and Linux operating systems with
  - reasonably recent Intel, GNU, and Clang compilers.
  It may not be an *optimal* build, but it should work.
- Use `semantic versioning <http://semver.org>`_ for your packages.

-------------------------------------------------------------------------------


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
.. _BLAS: https://www.wikiwand.com/en/Basic_Linear_Algebra_Subprograms
.. _CBLAS: http://www.netlib.org/blas/#_cblas
.. _LAPACK: http://www.netlib.org/lapack/

