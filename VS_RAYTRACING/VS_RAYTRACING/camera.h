#pragma once
#include "ray.h"
#include "Util.h"

class camera {
	private:
		glm::vec3 lower_left_corner;
		glm::vec3 horizontal;
		glm::vec3 vertical;
		glm::vec3 camOrigin;

	public:
		camera();
		~camera();
		
		ray getRay(float, float);
};