#pragma once

#include "Util.h"
#include "hitable.h"

class sphere : public hitable {
	private:
		glm::vec3 center;
		float radius;
		material *mat_ptr;

	public:
		__device__ sphere();
		__device__ sphere(glm::vec3, float, material*);
		__device__ virtual bool hit(const ray&, float, float, hit_record&) const;

		__host__ material* getMaterial()	{ return mat_ptr; }
		__host__ glm::vec3 getCenter()	{ return center; }
		__host__ float getRadius()		{ return radius; }
};


__device__ sphere::sphere() {}

__device__ sphere::sphere(glm::vec3 cen, float r, material *mat)
	: center(cen), radius(r), mat_ptr(mat) {}

__device__ bool sphere::hit(const ray &r, float t_min, float t_max, hit_record &rec) const {
	glm::vec3 oc = r.getOrigin() - center;
	float a = glm::dot(r.getDirection(), r.getDirection());
	float b = glm::dot(oc, r.getDirection());
	float c = glm::dot(oc, oc) - radius * radius;
	float disc = b * b - a * c;

	if (disc > 0) {
		float temp = (-b - glm::sqrt(disc)) / a;
		if (temp < t_max && temp > t_min) {
			rec.t = temp;
			rec.p = r.getPointAtParameter(rec.t);
			rec.normal = (rec.p - center) / radius;
			rec.mat_ptr = mat_ptr;
			return true;
		}

		temp = (-b + glm::sqrt(disc)) / a;
		if (temp < t_max && temp > t_min) {
			rec.t = temp;
			rec.p = r.getPointAtParameter(rec.t);
			rec.normal = (rec.p - center) / radius;
			rec.mat_ptr = mat_ptr;
			return true;
		}
	}
	return false;
}
