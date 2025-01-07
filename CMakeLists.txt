cmake_minimum_required(VERSION 3.15)
project(tkDNN)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
set(CMAKE_CXX_STANDARD 14)

option(ENABLE_OPENCV_CUDA_CONTRIB "Enable OpenCV CUDA Contrib" OFF )

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "default build" FORCE)
endif(NOT CMAKE_BUILD_TYPE)

find_package(CUDA 9.0 REQUIRED)
if (CUDA_FOUND)
    set(OUTPUTFILE ${CMAKE_CURRENT_SOURCE_DIR}/cmake/cuda_script) # No suffix required
    execute_process(COMMAND "rm ${OUTPUTFILE}")
    set(CUDAFILE ${CMAKE_CURRENT_SOURCE_DIR}/cmake/getCudaArch.cu)
    execute_process(COMMAND ${CUDA_NVCC_EXECUTABLE} -lcuda ${CUDAFILE} -o ${OUTPUTFILE})
    execute_process(COMMAND ${OUTPUTFILE}
            RESULT_VARIABLE CUDA_RETURN_CODE
            OUTPUT_VARIABLE ARCH)

    if(${CUDA_RETURN_CODE} EQUAL 0)
        set(CUDA_SUCCESS "TRUE")
    else()
        set(CUDA_SUCCESS "FALSE")
    endif()

    if (${CUDA_SUCCESS})
        message(STATUS "CUDA Architecture: ${ARCH}")
        message(STATUS "CUDA Version: ${CUDA_VERSION_STRING}")
        message(STATUS "CUDA Path: ${CUDA_TOOLKIT_ROOT_DIR}")
        message(STATUS "CUDA Libararies: ${CUDA_LIBRARIES}")
        message(STATUS "CUDA Performance Primitives: ${CUDA_npp_LIBRARY}")
        set(CUDA_NVCC_FLAGS "${ARCH}")
    else()
        message(WARNING ${ARCH})
    endif()
endif()

SET(CUDA_SEPARABLE_COMPILATION ON)

if(UNIX)
    if(CMAKE_BUILD_TYPE MATCHES Release)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}  -fPIC -Wno-deprecated-declarations -Wno-unused-variable -O3")
        set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS} --maxrregcount=32)
    endif()

    if(CMAKE_BUILD_TYPE MATCHES Debug)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}  -fPIC -Wno-deprecated-declarations -Wno-unused-variable -g3")
        set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS} --maxrregcount=32 -G -g)
    endif()
endif()

# project specific flags
if(DEBUG)
    add_definitions(-DDEBUG)
endif()

if(TKDNN_PATH)
    message("SET TKDNN_PATH:" ${TKDNN_PATH})
    add_definitions(-DTKDNN_PATH="${TKDNN_PATH}")
else()
    add_definitions(-DTKDNN_PATH="${CMAKE_CURRENT_SOURCE_DIR}")
endif()


#-------------------------------------------------------------------------------
# CUDA
#-------------------------------------------------------------------------------
set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS}" --compiler-options '-fPIC')


find_package(CUDNN REQUIRED)
include_directories(${CUDNN_INCLUDE_DIR})

find_package(yaml-cpp REQUIRED)


# compile
file(GLOB tkdnn_CUSRC "src/kernels/*.cu" "src/sorting.cu" "src/pluginsRT/*.cpp")
cuda_include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include ${CMAKE_CURRENT_SOURCE_DIR}/include/tkDNN ${CUDA_INCLUDE_DIRS} ${CUDNN_INCLUDE_DIRS})
cuda_add_library(kernels SHARED ${tkdnn_CUSRC})
target_link_libraries(kernels ${CUDA_CUBLAS_LIBRARIES} ${CUDA_LIBRARIES} ${CUDNN_LIBRARIES} yaml-cpp)



#-------------------------------------------------------------------------------
# External Libraries
#-------------------------------------------------------------------------------
find_package(Eigen3 REQUIRED)
message("Eigen DIR: " ${EIGEN3_INCLUDE_DIR})
include_directories(${EIGEN3_INCLUDE_DIR})

find_package(OpenCV REQUIRED)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DOPENCV")
if(ENABLE_OPENCV_CUDA_CONTRIB)
    if (OpenCV_FOUND)
        find_package(OpenCV COMPONENTS cudawarping cudaarithm)
        if(OpenCV_cudawarping_FOUND AND OpenCV_cudaarithm_FOUND)
            add_compile_definitions(OPENCV_CUDACONTRIB)
            message("OpenCV Cuda Contrib modules found")
        else()
            message("OpenCV Cuda Contrib modules not found")
            set(ENABLE_OPENCV_CUDA_CONTRIB OFF)
        endif()
    endif()
endif()

#-------------------------------------------------------------------------------
# Build Libraries
#-------------------------------------------------------------------------------
file(GLOB tkdnn_SRC "src/*.cpp")
set(tkdnn_LIBS kernels ${CUDA_LIBRARIES} ${CUDA_CUBLAS_LIBRARIES} ${CUDNN_LIBRARIES} ${OpenCV_LIBS} yaml-cpp)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include ${CMAKE_CURRENT_SOURCE_DIR}/include/tkDNN/ ${CUDA_INCLUDE_DIRS} ${OPENCV_INCLUDE_DIRS} ${NVINFER_INCLUDES})
add_library(tkDNN SHARED ${tkdnn_SRC})
target_link_libraries(tkDNN ${tkdnn_LIBS} ${CUDA_CUBLAS_LIBRARIES})



#-------------------------------------------------------------------------------
# Install
#-------------------------------------------------------------------------------
#if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
#    set (CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" 
#         CACHE PATH "default install path" FORCE)
#endif()
message("install dir:" ${CMAKE_INSTALL_PREFIX})
install(DIRECTORY include/ DESTINATION include/)
install(TARGETS tkDNN kernels DESTINATION lib)
# install(TARGETS test_simple test_mnist test_mnistRT test_rtinference demo map_demo DESTINATION bin)
install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/cmake/" # source directory
        DESTINATION "share/tkDNN/" # target directory
)
# install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/tests/" # source directory
#         DESTINATION "share/tkDNN/tests" # target directory
# )
