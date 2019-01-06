#pragma once

#include "Util.h"
#include <float.h>

class ray{
	public:
		__host__ __device__ ray();
		__device__ ray(const glm::vec3&, const glm::vec3&);
		
		__device__ void setRayParameters(const glm::vec3&, const glm::vec3&);
		
		__device__ glm::vec3 getOrigin() const;
		__device__ glm::vec3 getDirection() const;
		__device__ glm::vec3 getPointAtParameter(float) const;

	private:
		glm::vec3 origin;
		glm::vec3 dir;
};

__device__ ray::ray() {}

__device__ ray::ray(const glm::vec3 &A, const glm::vec3 &B) {
	origin = A;
	dir = B;
}

__device__ void ray::setRayParameters(const glm::vec3 &A, const glm::vec3 &B) {
	origin = A;
	dir = B;
}

__device__ glm::vec3 ray::getOrigin() const {
	return origin;
}

__device__ glm::vec3 ray::getDirection() const {
	return dir;
}

__device__ glm::vec3 ray::getPointAtParameter(float _time) const {
	glm::vec3 ret = dir * _time;
	ret += origin;
	return ret;
}
