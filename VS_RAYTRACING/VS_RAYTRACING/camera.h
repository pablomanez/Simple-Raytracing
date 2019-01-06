#pragma once
#include "Util.h"
#include "ray.h"

class camera {
	private:
		glm::vec3 lower_left_corner;
		glm::vec3 horizontal;
		glm::vec3 vertical;
		glm::vec3 camOrigin;

	public:
		__device__ camera();
		__device__ ray getRay(float, float);
};


__device__ camera::camera() {
	lower_left_corner = glm::vec3(-2.0, -1.0, -1.0);
	horizontal = glm::vec3(4.0, 0.0, 0.0);
	vertical = glm::vec3(0.0, 2.0, 0.0);
	camOrigin = glm::vec3(0.0, 0.0, 0.0);
}

__device__ ray camera::getRay(float u, float v) {
	return ray(camOrigin, lower_left_corner + u * horizontal + v * vertical - camOrigin);
}
