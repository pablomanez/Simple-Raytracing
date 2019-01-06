// Librerias
#include "Util.h"
#include "ray.h"
#include "sphere.h"
#include "hitable_list.h"
#include "hitable.h"
#include "camera.h"
#include "material.h"
#include "metal.h"
#include "lambertian.h"

__device__ glm::vec3 getColor(const ray& r, hitable *WORLD, int depth) {
	hit_record rec;
	if (WORLD->hit(r, 0.001, FLT_MAX, rec)) {
		ray scattered;
		glm::vec3 attenuation;
		if (depth < 50 && rec.mat_ptr->scatter(r, rec, attenuation, scattered)) {
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

int main(void) {
	//Establezco la GPU que voy a usar
	cudaSetDevice(0);

#define K_THREADS	8
#define K_BLOCKS	8
	
	// DATA 
	// ns es la precision del aliasing 
	const std::string filename = "img.PPM";
	int const total_hitables = 4;
	int ir, ig, ib, _w, _h, ns;
	glm::vec3 color;
	float u, v;
	ray r;

	std::ofstream _out(filename);
	_w = 200;
	_h = 100;
	ns = 100;
	
	// Definir variables que voy a usar en la GPU
	glm::vec3 *h_arr, *d_arr;	// Array de salida de cada color



	// hitable *list[total_hitables];
	// list[0] = new sphere(glm::vec3(0, 0, -1), 0.5, new lambertian(glm::vec3(0.8, 0.3, 0.3)));
	// list[1] = new sphere(glm::vec3(0, -100.5, -1), 100, new lambertian(glm::vec3(0.8, 0.8, 0.0)));
	// list[2] = new sphere(glm::vec3(1, 0, -1), 0.5, new metal(glm::vec3(0.8, 0.6, 0.2), 0.3));
	// list[3] = new sphere(glm::vec3(-1, 0, -1), 0.5, new metal(glm::vec3(0.8, 0.8, 0.8), 1.0));
	// hitable *WORLD = new hitable_list(list, total_hitables);
	// 
	// camera cam;

	// Inicio del archivo PPM
	//	P3  -> El archivo esta en ASCII
	//	255 -> Color 'maximo'
	// _out << "P3\n" << _w << " " << _h << "\n255\n";
	/*

	// ESTO DEBE IR EN UNA FUNCION GLOBAL
	for (int j = _h - 1; j >= 0; j--) {
		for (int i = 0; i < _w; i++) {
			color = glm::vec3(0, 0, 0);
			for (int s = 0; s < ns; s++) {
				u = float(i + UTIL_rand_d()) / float(_w);
				v = float(j + UTIL_rand_d()) / float(_h);
				ray r = cam.getRay(u, v);
				color += getColor(r, WORLD, 0);
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
	*/

	// Libero la GPU
	// TODO: 
	//		Liberar el espacio reservado de la gpu
	cudaDeviceReset();

	std::cout << "Finalizado" << '\n';
}

// PRUEBA CON GLM QUE FUNCIONA
/*

__global__ void molona(glm::vec3 *s_ptr, glm::vec3 *_arr) {
	int idx_ = blockIdx.x * blockDim.x + threadIdx.x;
	
	float mult = idx_ + 1;
	s_ptr[idx_] = mult * _arr[idx_];
}

int main(void) {
	//Establezco la GPU que voy a usar
	cudaSetDevice(0);

	////////////////////////////////////////////
	// DEFINIR ESTRUCTURA DE LOS BLOQUES
	#define K_THREADS	3
	#define K_BLOCKS	1

	glm::vec3 *d_arr = NULL;				// DEVICE
	glm::vec3 *h_arr = new glm::vec3[3];	// HOST
		h_arr[0] = glm::vec3(1, 1, 1);
		h_arr[1] = glm::vec3(1, 1, 1);
		h_arr[2] = glm::vec3(1, 1, 1);

	// Memoria a reservar para la GPU
	int mem = sizeof(glm::vec3) * 3;

	// Reserva de memoria en la CPU
	// NOTA: Creo que ambas formas son v�lidas
	glm::vec3 *d_str = NULL;				// DEVICE
	glm::vec3 *h_str = new glm::vec3[3];	// HOST
	// glm::vec3 *h_str = (glm::vec3*)malloc(mem);

	// Reservo memoria en la GPU
	cudaMalloc((void**)&d_str, mem);
	cudaMalloc((void**)&d_arr, mem);

	cudaMemcpy(d_arr, h_arr, mem, cudaMemcpyHostToDevice);

	dim3 tpb(K_THREADS, 1, 1);	// Hilos por bloque		(THREADS PER BLOCK)
	dim3 bpg(K_BLOCKS, 1, 1);	// Bloques por malla	(BLOCKS PER GRID)

	molona << < bpg, tpb >> > (d_str, d_arr);

	// cudaError_t err_ = cudaGetLastError();
	// if (err_ != cudaSuccess) {
	// 	std::cerr << "Error " << cudaGetErrorString(err_) << "\n";
	// }

	cudaMemcpy(h_str, d_str, mem, cudaMemcpyDeviceToHost);
	cudaMemcpy(h_arr, d_arr, mem, cudaMemcpyDeviceToHost);

	for (int i = 0; i < 3; i++) {
		std::cout << "ORIGINAL: (" << h_arr[i].x << "," << h_arr[i].y << "," << h_arr[i].z << ")" << std::endl;
	}
	for (int i = 0; i < 3; i++) {
		std::cout << "    HOST: (" << h_str[i].x << "," << h_str[i].y << "," << h_str[i].z << ")" << std::endl;
	}
	
	//Libero la GPU
	cudaDeviceReset();

	std::cout << "Finalizado" << '\n';
}
*/

// Cuanta memoria tengo que reservar en la GPU?
// DATA			->	SIZE (bytes)
// -------------  -------------- ----------------------------------- ----------- --- -
// camera		->	48			: 4*glm::vec3						: 4*12		= 48
// sphere		->	32			: glm::vec3+float+material+hitable	: 12+4+8+8	= 32
// lambertian	->	24			: glm::vec3+material+?????			: 12+8+4	= 24
// metal		->	24			: glm::vec3+float+material			: 12+4+8	= 24
// hitable_list	->	24			: hitable**+int+hitable+?????		: 8+2+8+6	= 24
// ray			->	24			: 2*glm::vec3						: 2*12		= 24
// glm::vec3	->	12			: 3*float							: 3*4		= 12
// material		->	8
// hitable		->	8
// double		->	8
// float		->	4
// int/bool		->	2
// --------------------------------------------------------------------------------- -

/*
NOTAS:
	Cada hilo ataca a un pixel de la imagen y se encarga de computar un color
	Ese color se almacena en la misma posicion que se le ha dado al del hilo en el total
	Es decir:
		(EJEMPLO: HILOS/BLOQUE = 100)
		El HILO 0 del BLOQUE 0 escribira en la posicion 0 del array	de salida
		El HILO 50 del BLOQUE 0 escribira en la posicion 50 del array de salida
		El HILO 10 del BLOQUE 1 escribira en la posicion 110 del array de salida
		El HILO 99 del BLOQUE 2 escribira en la posicion 299 del array de salida

	Despu�s, ese array DEBE SER llevado, usando la CPU, al fichero de salida para tener la imagen final

OBSERVACIONES:
	Un hilo utiliza los mismos datos para computar el color que cualquier otro hilo que se lance -> MEMORIA COMPARTIDA?

COMO COJONES LO HE HECHO:
	Cambiar la estructura de las clases, porque no compila ^^
	Mover todo al .h
	Leer MUCHA documentaci�n

PASOS:
	1. Reservar la GPU y la memoria a usar
	2. Organizar bloques e hilos
	3. Llamada a funcion/es
	4. Liberacion de la memoria y la GPU
*/
// https://devblogs.nvidia.com/accelerated-ray-tracing-cuda/
// --------------------------------------------