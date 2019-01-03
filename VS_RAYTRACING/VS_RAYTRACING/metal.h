#pragma once

#include "Util.h"
#include "ray.h"
#include "material.h"

class metal : public material {
	private:
		glm::vec3 albedo;
	public:
		metal(const glm::vec3&);
		virtual bool scatter(const ray&, const hit_record&, glm::vec3&, ray&) const;
};