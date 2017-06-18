{ fetchurl, stdenv, cmake, qt5
, mpich2
, python
, libxml2
, mesa, libXt
, boost, silo
, fortranSupport ? true
, gfortran
}:

stdenv.mkDerivation rec {
  name = "paraview-5.4.0";
  src = fetchurl {
    url = "http://paraview.org/files/v5.4/ParaView-v5.4.0.tar.gz";
    sha256 = "1aclkx8jy12yinmbsv2fzsk0bbf84rk3hzlnw4p6sa5iad5di27l";
  };

  # [  5%] Generating vtkGLSLShaderLibrary.h
  # ../../../bin/ProcessShader: error while loading shared libraries: libvtksys.so.pv3.10: cannot open shared object file: No such file or directory
  preConfigure = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $out/lib/paraview-5.40 -rpath ../../../../../../lib -rpath ../../../../../lib -rpath ../../../../lib -rpath ../../../lib -rpath ../../lib -rpath ../lib -ldl -lz"
  '';

  # [100%] Compiling Qt help project SurfaceLIC.qhp
  # /nix/store/wb34dgkpmnssjkq7yj4qbjqxpnapq0lw-bash-4.4-p12/bin/bash: line 0: cd: /tmp/nix-build-paraview-5.4.0.drv-0/ParaView-v5.4.0/build/Plugins/SurfaceLIC/doc: No such file or directory
  preBuild = ''
    mkdir -p Plugins/SurfaceLIC/doc
  '';

  cmakeFlags = [
    "-DPARAVIEW_USE_MPI:BOOL=ON"
## /nix/store/2qf1qgqkkalmdpfby9pwc1l7knnxy5hn-hdf5-1.8.14/lib/libhdf5_hl.a(H5LT.c.o): In function `H5LT_dtype_to_text':
## (.text+0x2adc): undefined reference to `H5Tget_cset'
#    "-DVTK_USE_SYSTEM_HDF5:BOOL=ON"
    "-DVTK_USE_SYSTEM_LIBXML2:BOOL=ON"
    "-DPARAVIEW_ENABLE_PYTHON:BOOL=ON"
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
    "-DPARAVIEW_INSTALL_DEVELOPMENT_FILES=ON"

    "-DPARAVIEW_DATA_EXCLUDE_FROM_ALL:BOOL=ON"
    "-DBUILD_TESTING=OFF"
    # http://www.paraview.org/Wiki/VisIt_Database_Bridge
    "-DPARAVIEW_USE_VISITBRIDGE:BOOL=ON"
    "-DVISIT_BUILD_READER_Silo:BOOL=ON"

    "-DPARAVIEW_ENABLE_CATALYST=ON"

# [100%] Compiling Qt help project SurfaceLIC.qhp
# This application failed to start because it could not find or load the Qt platform plugin "minimal"
# in "".
    "-DPARAVIEW_BUILD_PLUGIN_SurfaceLIC=OFF"
# [100%] Compiling Qt help project paraview.qhp
# This application failed to start because it could not find or load the Qt platform plugin "minimal"
# in "".
# 
# Reinstalling the application may fix this problem.
# make[2]: *** [Applications/ParaView/Documentation/CMakeFiles/vtkParaViewDocumentation.dir/build.make:69: Applications/ParaView/Documentation/paraview.qch] Aborted
# make[1]: *** [CMakeFiles/Makefile2:49323: Applications/ParaView/Documentation/CMakeFiles/vtkParaViewDocumentation.dir/all] Error 2

  ];

  # https://bugzilla.redhat.com/show_bug.cgi?id=1138466
  NIX_CFLAGS_COMPILE = "-DGLX_GLXEXT_LEGACY";

  enableParallelBuilding = true;

  buildInputs = [ cmake qt5.qtbase qt5.qtx11extras qt5.qttools mpich2 python libxml2 mesa libXt boost silo
    ] ++ stdenv.lib.optionals fortranSupport [ gfortran ];

  meta = {
    homepage = http://www.paraview.org/;
    description = "3D Data analysis and visualization application";
    license = stdenv.lib.licenses.free;
    maintainers = with stdenv.lib.maintainers; [viric guibert];
    platforms = with stdenv.lib.platforms; linux;
  };
}
