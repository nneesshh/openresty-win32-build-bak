# CMake generated Testfile for 
# Source directory: D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42
# Build directory: D:/www/_openresty/openresty-1.13.6.2/thirdparty/pcre-8.42/build
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
if("${CTEST_CONFIGURATION_TYPE}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
  add_test(pcre_test_bat "pcre_test.bat")
  set_tests_properties(pcre_test_bat PROPERTIES  PASS_REGULAR_EXPRESSION "RunTest\\.bat tests successfully completed")
elseif("${CTEST_CONFIGURATION_TYPE}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
  add_test(pcre_test_bat "pcre_test.bat")
  set_tests_properties(pcre_test_bat PROPERTIES  PASS_REGULAR_EXPRESSION "RunTest\\.bat tests successfully completed")
elseif("${CTEST_CONFIGURATION_TYPE}" MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
  add_test(pcre_test_bat "pcre_test.bat")
  set_tests_properties(pcre_test_bat PROPERTIES  PASS_REGULAR_EXPRESSION "RunTest\\.bat tests successfully completed")
elseif("${CTEST_CONFIGURATION_TYPE}" MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
  add_test(pcre_test_bat "pcre_test.bat")
  set_tests_properties(pcre_test_bat PROPERTIES  PASS_REGULAR_EXPRESSION "RunTest\\.bat tests successfully completed")
else()
  add_test(pcre_test_bat NOT_AVAILABLE)
endif()
add_test(pcrecpp_test "pcrecpp_unittest")
add_test(pcre_scanner_test "pcre_scanner_unittest")
add_test(pcre_stringpiece_test "pcre_stringpiece_unittest")
