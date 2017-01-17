This is BootsOnTheGround [BOTG_]!
=================================

BOTG_ provides a set of FindTPL*.cmake files to find and link Third Party
Libraries (TPLs) to other packages using the CMake / TriBITS_ framework
for C/C++/Fortran code.

Currently it provides TPLs for
- GTest_ -- Google's C++ unit testing system
- BoostFilesystem_ -- Cross-platform file system queries

Principles
----------
- All TPLs must be linkable with ``mkdir build && cd build && cmake ..`` on 
  - Windows, Mac, and Linux operating systems with 
  - Intel, GNU, and Clang compilers
  and perform correctly. This implies that we need a way to download and install
  packages (we use Hunter_).
- All TPLS must have permissible, 
  `non-copyleft licenses<http://fosslawyers.org/permissive-foss-licenses-bsd-apache-mit/>`_. 
  We need these TPLs in our open source TriBITS_ projects, but also in special, 
  export-controlled nuclear reactor simulations like CASL_.
- All TPLs should use `semantic versioning<http://semver.org/>`_ with the ability
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
.. _TriBITS: https://tribits.org/
.. _BOTG: http://github.com/wawiesel/BootsOnTheGround
.. _GTest: http://github.com/google/googletest
.. _BoostFilesystem: http://www.boost.org/doc/libs/1_63_0/libs/filesystem/doc/reference.html
.. _CASL: http://www.casl.gov/
