#pragma once

#include "Util.h"
#include "ray.h"
#include "material.h"

class metal : public material {
	private:
		glm::vec3 albedo;
		float fuzz;
	public:
		metal(const glm::vec3&, float);
		virtual bool scatter(const ray&, const hit_record&, glm::vec3&, ray&) const;
};