# Install script for directory: D:/www/_openresty/openresty-1.13.6.2/thirdparty/libtiff-master

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "C:/Program Files (x86)/tiff")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "C:/Program Files (x86)/tiff/lib/pkgconfig/libtiff-4.pc")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "C:/Program Files (x86)/tiff/lib/pkgconfig" TYPE FILE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/libtiff-master/build/libtiff-4.pc")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("D:/www/_openresty/openresty-1.13.6.2/thirdparty/libtiff-master/build/port/cmake_install.cmake")
  include("D:/www/_openresty/openresty-1.13.6.2/thirdparty/libtiff-master/build/libtiff/cmake_install.cmake")
  include("D:/www/_openresty/openresty-1.13.6.2/thirdparty/libtiff-master/build/tools/cmake_install.cmake")
  include("D:/www/_openresty/openresty-1.13.6.2/thirdparty/libtiff-master/build/test/cmake_install.cmake")
  include("D:/www/_openresty/openresty-1.13.6.2/thirdparty/libtiff-master/build/contrib/cmake_install.cmake")
  include("D:/www/_openresty/openresty-1.13.6.2/thirdparty/libtiff-master/build/build/cmake_install.cmake")
  include("D:/www/_openresty/openresty-1.13.6.2/thirdparty/libtiff-master/build/man/cmake_install.cmake")
  include("D:/www/_openresty/openresty-1.13.6.2/thirdparty/libtiff-master/build/html/cmake_install.cmake")

endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "D:/www/_openresty/openresty-1.13.6.2/thirdparty/libtiff-master/build/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
