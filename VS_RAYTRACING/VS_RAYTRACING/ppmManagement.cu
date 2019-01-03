#include "ppmManagement.h"

ppmManagement::ppmManagement(){}
ppmManagement::~ppmManagement(){}

glm::vec3 ppmManagement::getColor(const ray& r, hitable *WORLD, int depth) {
	hit_record rec;
	if (WORLD->hit(r, 0.001, FLT_MAX, rec)) {
		ray scattered;
		glm::vec3 attenuation;
		if (depth < 50 && rec.mat_ptr->scatter(r,rec,attenuation,scattered)) {
			return attenuation * getColor(scattered, WORLD, depth + 1);
		}
		else {
			return glm::vec3(0, 0, 0);
		}
	}
	else {
		glm::vec3 unitDirection = glm::normalize(r.getDirection());
		float t = 0.5 * (unitDirection.y + 1.0f);
		return ((1.0f - t) * glm::vec3(1.f)) + (t * glm::vec3(0.5, 0.7, 1.0));
	}
}

void ppmManagement::createImage(int _w, int _h, int ns, const std::string &_name) {
	// ns es la precision del aliasing 
	// ns = 100 (default)
	std::ofstream _out(_name);
	int ir, ig, ib;
	float u,v;
	ray r;
	glm::vec3 color;

	int const total_hitables = 4;
	hitable *list[total_hitables];
	list[0] = new sphere(glm::vec3(0, 0, -1), 0.5, new lambertian(glm::vec3(0.8, 0.3, 0.3)));
	list[1] = new sphere(glm::vec3(0, -100.5, -1), 100, new lambertian(glm::vec3(0.8, 0.8, 0.0)));
	list[2] = new sphere(glm::vec3(1,0,-1), 0.5, new metal(glm::vec3(0.8, 0.6, 0.2),0.3));
	list[3] = new sphere(glm::vec3(-1,0,-1), 0.5, new metal(glm::vec3(0.8, 0.8, 0.8),1.0));
	hitable *WORLD = new hitable_list(list, total_hitables);

	camera cam;
	
	// Inicio del archivo PPM
	//	P3  -> El archivo esta en ASCII
	//	255 -> Color 'maximo'
	_out << "P3\n" << _w << " " << _h << "\n255\n";
	for (int j = _h - 1; j >= 0; j--) {
		for (int i = 0; i < _w; i++) {
			color = glm::vec3(0, 0, 0);
			for (int s = 0; s < ns; s++) {
				u = float(i + UTIL_rand_d()) / float(_w);
				v = float(j + UTIL_rand_d()) / float(_h);
				r = cam.getRay(u, v);
				color += getColor(r, WORLD,0);
			}

			color /= float(ns);
			color = glm::vec3(glm::sqrt(color.r), glm::sqrt(color.g), glm::sqrt(color.b));
			ir = int(255.99 * color.r);
			ig = int(255.99 * color.g);
			ib = int(255.99 * color.b);

			// Valores de los pixeles
			_out << ir << " ";
			_out << ig << " ";
			_out << ib << "\n";
		}
	}
}
