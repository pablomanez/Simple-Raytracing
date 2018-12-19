#include "ray.h"

#define SPHERE_CENTER glm::vec3(0,0,-1)
#define SPHERE_RADIUS 0.5

ray::ray() {};
ray::~ray(){}

bool ray::hitSphere(const glm::vec3 &center, float radius) {
	glm::vec3 oc = origin - center;
	float a = glm::dot(dir, dir);
	float b = 2.0*glm::dot(oc,dir);
	float c = glm::dot(oc,oc) - radius*radius;
	float disc = b * b - 4 * a*c;
	return (disc > 0);
}


glm::vec3 ray::getColor() {
	if (hitSphere(SPHERE_CENTER, SPHERE_RADIUS)) {
		return glm::vec3(1, 0, 0);
	}
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
