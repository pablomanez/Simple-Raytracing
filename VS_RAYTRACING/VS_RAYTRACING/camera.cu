#include "camera.h"

camera::camera() {
	lower_left_corner = glm::vec3(-2.0, -1.0, -1.0);
	horizontal = glm::vec3(4.0, 0.0, 0.0);
	vertical = glm::vec3(0.0, 2.0, 0.0);
	camOrigin = glm::vec3(0.0, 0.0, 0.0);
}
camera::~camera() {}

ray camera::getRay(float u, float v) {
	return ray(camOrigin, lower_left_corner + u * horizontal + v * vertical - camOrigin);
}
