#include "ray.h"

ray::ray() {}
ray::~ray(){}

ray::ray(const glm::vec3 &A, const glm::vec3 &B){
	origin = A;
	dir = B;
}

void ray::setRayParameters(const glm::vec3 &A, const glm::vec3 &B) {
	origin = A;
	dir = B;
}

glm::vec3 ray::getOrigin() const {
	return origin;
}

glm::vec3 ray::getDirection() const {
	return dir;
}

glm::vec3 ray::getPointAtParameter(float _time) const {
	glm::vec3 ret = dir * _time;
	ret += origin;
	return ret;
}
