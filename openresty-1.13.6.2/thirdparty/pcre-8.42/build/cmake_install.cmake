# Install script for directory: D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "C:/Program Files (x86)/PCRE")
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
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/Debug/pcred.lib")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/Release/pcre.lib")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/MinSizeRel/pcre.lib")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/RelWithDebInfo/pcre.lib")
  endif()
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/Debug/pcreposixd.lib")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/Release/pcreposix.lib")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/MinSizeRel/pcreposix.lib")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/RelWithDebInfo/pcreposix.lib")
  endif()
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/Debug/pcrecppd.lib")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/Release/pcrecpp.lib")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/MinSizeRel/pcrecpp.lib")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/RelWithDebInfo/pcrecpp.lib")
  endif()
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/Debug/pcregrep.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/Release/pcregrep.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/MinSizeRel/pcregrep.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/RelWithDebInfo/pcregrep.exe")
  endif()
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/Debug/pcretest.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/Release/pcretest.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/MinSizeRel/pcretest.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/RelWithDebInfo/pcretest.exe")
  endif()
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/Debug/pcrecpp_unittest.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/Release/pcrecpp_unittest.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/MinSizeRel/pcrecpp_unittest.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/RelWithDebInfo/pcrecpp_unittest.exe")
  endif()
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/Debug/pcre_scanner_unittest.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/Release/pcre_scanner_unittest.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/MinSizeRel/pcre_scanner_unittest.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/RelWithDebInfo/pcre_scanner_unittest.exe")
  endif()
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/Debug/pcre_stringpiece_unittest.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/Release/pcre_stringpiece_unittest.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/MinSizeRel/pcre_stringpiece_unittest.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/RelWithDebInfo/pcre_stringpiece_unittest.exe")
  endif()
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/pcre.h"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/pcreposix.h"
    )
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/pcrecpp.h"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/pcre_scanner.h"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/pcrecpparg.h"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/pcre_stringpiece.h"
    )
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/man/man1" TYPE FILE FILES
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre-config.1"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcregrep.1"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcretest.1"
    )
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/man/man3" TYPE FILE FILES
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre16.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre32.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_assign_jit_stack.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_compile.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_compile2.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_config.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_copy_named_substring.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_copy_substring.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_dfa_exec.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_exec.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_free_study.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_free_substring.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_free_substring_list.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_fullinfo.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_get_named_substring.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_get_stringnumber.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_get_stringtable_entries.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_get_substring.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_get_substring_list.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_jit_exec.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_jit_stack_alloc.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_jit_stack_free.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_maketables.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_pattern_to_host_byte_order.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_refcount.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_study.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_utf16_to_host_byte_order.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_utf32_to_host_byte_order.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcre_version.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcreapi.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcrebuild.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcrecallout.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcrecompat.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcrecpp.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcredemo.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcrejit.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcrelimits.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcrematching.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcrepartial.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcrepattern.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcreperform.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcreposix.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcreprecompile.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcresample.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcrestack.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcresyntax.3"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/pcreunicode.3"
    )
endif()

if("${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/doc/pcre/html" TYPE FILE FILES
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/index.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre-config.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre16.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre32.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_assign_jit_stack.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_compile.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_compile2.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_config.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_copy_named_substring.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_copy_substring.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_dfa_exec.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_exec.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_free_study.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_free_substring.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_free_substring_list.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_fullinfo.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_get_named_substring.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_get_stringnumber.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_get_stringtable_entries.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_get_substring.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_get_substring_list.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_jit_exec.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_jit_stack_alloc.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_jit_stack_free.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_maketables.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_pattern_to_host_byte_order.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_refcount.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_study.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_utf16_to_host_byte_order.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_utf32_to_host_byte_order.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcre_version.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcreapi.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcrebuild.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcrecallout.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcrecompat.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcrecpp.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcredemo.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcregrep.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcrejit.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcrelimits.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcrematching.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcrepartial.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcrepattern.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcreperform.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcreposix.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcreprecompile.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcresample.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcrestack.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcresyntax.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcretest.html"
    "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/doc/html/pcreunicode.html"
    )
endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
