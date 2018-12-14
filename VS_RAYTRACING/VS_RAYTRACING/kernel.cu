#include "cuda_runtime.h"
#include "device_launch_parameters.h"

// Librerias
#include <iostream>
#include <fstream>

#define GLM_FORCE_PURE
#include <glm/glm.hpp>

int main(void) {
	glm::vec3 color;
	int ir, ig, ib;
	int nx = 200;	// Ancho
	int ny = 100;	// Alto

	std::ofstream _out("img.PPM");

	// Inicio del archivo PPM
	//	P3  -> El archivo esta en ASCII
	//	255 -> Color 'maximo'
	_out << "P3\n" << nx << " " << ny << "\n255\n";
	for (int j = ny - 1; j >= 0; j--) {
		for (int i = 0; i < nx; i++) {
			color = glm::vec3(
				float(i) / float(nx),
				float(j) / float(ny),
				0.2
			);

			ir = int(255.99 * color.r);
			ig = int(255.99 * color.g);
			ib = int(255.99 * color.b);

			// Valores de los pixeles
			_out << ir << " " << ig << " " << ib << "\n";
		}
		std::cout << j << '\n';
	}
	std::cout << "Finalizado" << '\n';

	// La finale
	getchar();
	exit(-1);


}
