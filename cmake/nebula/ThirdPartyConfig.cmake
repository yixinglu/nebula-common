message(">>>> Configuring third party for '${PROJECT_NAME}' <<<<")
# The precedence to decide NEBULA_THIRDPARTY_ROOT is:
#   1. The path defined with CMake argument, i.e -DNEBULA_THIRDPARTY_ROOT=path
#   2. ${CMAKE_BINARY_DIR}/third-party/install, if exists
#   3. The path specified with environment variable NEBULA_THIRDPARTY_ROOT=path
#   4. /opt/vesoft/third-party, if exists
#   5. At last, one copy will be downloaded and installed to ${CMAKE_BINARY_DIR}/third-party/install
if("${NEBULA_THIRDPARTY_ROOT}" STREQUAL "")
    if(EXISTS ${CMAKE_BINARY_DIR}/third-party/install)
        SET(NEBULA_THIRDPARTY_ROOT ${CMAKE_BINARY_DIR}/third-party/install)
    elseif(NOT $ENV{NEBULA_THIRDPARTY_ROOT} STREQUAL "")
        SET(NEBULA_THIRDPARTY_ROOT $ENV{NEBULA_THIRDPARTY_ROOT})
    elseif(EXISTS /opt/vesoft/third-party)
        SET(NEBULA_THIRDPARTY_ROOT "/opt/vesoft/third-party")
    else()
        include(InstallThirdParty)
    endif()
endif()

if(NOT ${NEBULA_THIRDPARTY_ROOT} STREQUAL "")
    message(STATUS "NEBULA_THIRDPARTY_ROOT  : ${NEBULA_THIRDPARTY_ROOT}")
    list(INSERT CMAKE_INCLUDE_PATH 0 ${NEBULA_THIRDPARTY_ROOT}/include)
    list(INSERT CMAKE_LIBRARY_PATH 0 ${NEBULA_THIRDPARTY_ROOT}/lib)
    list(INSERT CMAKE_LIBRARY_PATH 0 ${NEBULA_THIRDPARTY_ROOT}/lib64)
    list(INSERT CMAKE_PROGRAM_PATH 0 ${NEBULA_THIRDPARTY_ROOT}/bin)
    include_directories(SYSTEM ${NEBULA_THIRDPARTY_ROOT}/include)
    link_directories(
        ${NEBULA_THIRDPARTY_ROOT}/lib
        ${NEBULA_THIRDPARTY_ROOT}/lib64
    )
endif()

if(NOT ${NEBULA_OTHER_ROOT} STREQUAL "")
    string(REPLACE ":" ";" DIR_LIST ${NEBULA_OTHER_ROOT})
    list(LENGTH DIR_LIST len)
    foreach(DIR IN LISTS DIR_LIST )
        list(INSERT CMAKE_INCLUDE_PATH 0 ${DIR}/include)
        list(INSERT CMAKE_LIBRARY_PATH 0 ${DIR}/lib)
        list(INSERT CMAKE_PROGRAM_PATH 0 ${DIR}/bin)
        include_directories(SYSTEM ${DIR}/include)
        link_directories(${DIR}/lib)
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -L ${DIR}/lib")
    endforeach()
endif()

string(REPLACE ";" ":" INCLUDE_PATH_STR "${CMAKE_INCLUDE_PATH}")
string(REPLACE ";" ":" LIBRARY_PATH_STR "${CMAKE_LIBRARY_PATH}")
string(REPLACE ";" ":" PROGRAM_PATH_STR "${CMAKE_PROGRAM_PATH}")
message(STATUS "CMAKE_INCLUDE_PATH      : ${INCLUDE_PATH_STR}")
message(STATUS "CMAKE_LIBRARY_PATH      : ${LIBRARY_PATH_STR}")
message(STATUS "CMAKE_PROGRAM_PATH      : ${PROGRAM_PATH_STR}")

find_package(Bzip2 REQUIRED)
find_package(DoubleConversion REQUIRED)
find_package(Fatal REQUIRED)
find_package(Fbthrift REQUIRED)
find_package(Folly REQUIRED)
find_package(Gflags REQUIRED)
find_package(Glog REQUIRED)
find_package(Googletest REQUIRED)
if(ENABLE_JEMALLOC)
    find_package(Jemalloc REQUIRED)
endif()
find_package(Libevent REQUIRED)
find_package(Mstch REQUIRED)
find_package(Proxygen REQUIRED)
find_package(Rocksdb REQUIRED)
find_package(Snappy REQUIRED)
find_package(Wangle REQUIRED)
find_package(ZLIB REQUIRED)
find_package(Zstd REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(Krb5 REQUIRED gssapi)
find_package(Boost REQUIRED)
find_package(GPERF 2.8 REQUIRED)
find_package(Libunwind REQUIRED)
find_package(BISON 3.0.5 REQUIRED)
include(MakeBisonRelocatable)
find_package(FLEX REQUIRED)
find_package(Readline REQUIRED)
find_package(NCURSES REQUIRED)
find_package(LibLZMA REQUIRED)

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -L ${NEBULA_THIRDPARTY_ROOT}/lib")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -L ${NEBULA_THIRDPARTY_ROOT}/lib64")

# All thrift libraries
set(THRIFT_LIBRARIES
    thriftcpp2
    thrift
    thriftprotocol
    async
    protocol
    transport
    concurrency
    security
    thriftfrozen2
    thrift-core
    wangle
)

set(ROCKSDB_LIBRARIES ${Rocksdb_LIBRARY})

# All compression libraries
set(COMPRESSION_LIBRARIES bz2 snappy zstd z lz4)
if (LIBLZMA_FOUND)
    include_directories(SYSTEM ${LIBLZMA_INCLUDE_DIRS})
    list(APPEND COMPRESSION_LIBRARIES ${LIBLZMA_LIBRARIES})
endif()

if (NOT ENABLE_JEMALLOC OR ENABLE_ASAN OR ENABLE_UBSAN)
    set(JEMALLOC_LIB )
else()
    set(JEMALLOC_LIB jemalloc)
endif()

execute_process(
    COMMAND ldd --version
    COMMAND head -1
    COMMAND cut -d ")" -f 2
    COMMAND cut -d " " -f 2
    OUTPUT_VARIABLE GLIBC_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
message(STATUS "Glibc version is " ${GLIBC_VERSION})

if (GLIBC_VERSION VERSION_LESS "2.17")
    set(GETTIME_LIB rt)
else()
    set(GETTIME_LIB)
endif()

message(">>>> Configuring third party for '${PROJECT_NAME}' done <<<<")
