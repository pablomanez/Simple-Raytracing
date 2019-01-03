#pragma once

#include "hitable.h"
#include "Util.h"

class sphere : public hitable {
	private:
		glm::vec3 center;
		float radius;
		material *mat_ptr;

	public:
		sphere();
		~sphere();
		sphere(glm::vec3, float, material*);
		virtual bool hit(const ray&, float, float, hit_record&) const;
};