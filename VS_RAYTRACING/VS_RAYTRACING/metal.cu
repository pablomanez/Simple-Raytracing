#include "metal.h"

metal::metal(const glm::vec3 &a) {
	albedo = a;
}

bool metal::scatter(const ray &r_in, const hit_record &rec, glm::vec3 &attenuation, ray &scattered) const {
	glm::vec3 reflected = glm::reflect(glm::normalize(r_in.getDirection()), rec.normal);
	scattered = ray(rec.p, reflected);
	attenuation = albedo;
	return true;
}