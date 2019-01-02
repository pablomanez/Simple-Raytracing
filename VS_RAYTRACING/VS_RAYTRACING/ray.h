#pragma once

#include "Util.h"
#include <float.h>

class ray{
	public:
		ray();
		ray(const glm::vec3&, const glm::vec3&);
		~ray();
			
		void setRayParameters(const glm::vec3&, const glm::vec3&);

		glm::vec3 getOrigin() const;
		glm::vec3 getDirection() const;
		glm::vec3 getPointAtParameter(float) const;

	private:
		glm::vec3 origin;
		glm::vec3 dir;
};
