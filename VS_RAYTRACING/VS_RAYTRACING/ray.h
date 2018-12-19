#pragma once
#include "Util.h"

class ray{
	public:
		ray();
		ray(const glm::vec3&, const glm::vec3&);
		~ray();
			
		void setRayParameters(const glm::vec3&, const glm::vec3&);

		bool hitSphere(const glm::vec3&, float);
		glm::vec3 getColor();
		glm::vec3 getOrigin();
		glm::vec3 getDirection();
		glm::vec3 getPointAtParameter(float);

	private:
		glm::vec3 origin;
		glm::vec3 dir;
};
