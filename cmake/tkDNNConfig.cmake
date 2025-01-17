message("-- Found tkDNN")
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} --std=c++11 -fPIC")

find_package(CUDA REQUIRED)
find_package(OpenCV REQUIRED)
find_package(CUDNN REQUIRED)

set(tkDNN_INCLUDE_DIRS 
	${CUDA_INCLUDE_DIRS} 
	${OPENCV_INCLUDE_DIRS} 
    ${CUDNN_INCLUDE_DIRS}
    /usr/local/include/
)

set(tkDNN_LIBRARIES 
    /usr/local/lib/libtkDNN.so 
    /usr/local/lib/libkernels.so  
    tkDNN 
    kernels 
    ${CUDA_LIBRARIES} 
    ${CUDA_CUBLAS_LIBRARIES}
	${CUDNN_LIBRARIES}
	${OpenCV_LIBS}
)

set(tkDNN_FOUND true)
