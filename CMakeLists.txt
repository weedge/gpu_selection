cmake_minimum_required(VERSION 3.8 FATAL_ERROR)
project(gpu_selection LANGUAGES CXX CUDA)

MESSAGE(STATUS "CMAKE_CUDA_FLAGS: ${CMAKE_CUDA_FLAGS}")
#list(APPEND CMAKE_CUDA_FLAGS "-rdc=true --maxrregcount 64 -gencode=arch=compute_50,code=sm_50 -gencode=arch=compute_52,code=sm_52 -gencode=arch=compute_60,code=sm_60 -gencode=arch=compute_70,code=sm_70 -gencode=arch=compute_75,code=compute_75 -gencode=arch=compute_80,code=sm_80")
option(BUILD_SHARED_LIBS "" ON)

add_subdirectory(lib)
#add_subdirectory(app)

