#include "ray.h"

ray::ray() {};
ray::~ray(){}

glm::vec3 ray::getColor() {
	glm::vec3 unitDirection = glm::normalize(dir);
	float t = 0.5 * (unitDirection.y + 1.0f);
	return ((1.f - t) * glm::vec3(1.f)) + (t * glm::vec3(0.5, 0.7, 1.0));
}

ray::ray(const glm::vec3 &A, const glm::vec3 &B){
	origin = A;
	dir = B;
}


void ray::setRayParameters(const glm::vec3 &A, const glm::vec3 &B) {
	origin = A;
	dir = B;
}

glm::vec3 ray::getOrigin() {
	return origin;
}

glm::vec3 ray::getDirection() {
	return dir;
}

glm::vec3 ray::getPointAtParameter(float _time) {
	return origin + (dir*_time);
}
