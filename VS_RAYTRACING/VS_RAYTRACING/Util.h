#pragma once

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <iostream>
#include <fstream>
#include <string>
#include <random>
#include <vector>
#include <array>

#include <cuda.h>
#define GLM_FORCE_PURE
#define GLM_FORCE_CUDA
#include <glm/glm.hpp>

__device__ inline double UTIL_rand_d(double min = 0.0, double max = 1.0) {
	// return ((double)rand() * (max - min)) / (double)RAND_MAX + min;
	return 1;
}

__device__ inline glm::vec3 randomInUnitSphere() {
	glm::vec3 p;
	do {
		p = 2.0f*glm::vec3(UTIL_rand_d(), UTIL_rand_d(), UTIL_rand_d()) - glm::vec3(1, 1, 1);
	} while ((glm::length(p)*glm::length(p)) >= 1.0);
	return p;
}