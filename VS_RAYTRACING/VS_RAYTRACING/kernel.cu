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

__device__ glm::vec3 getColor(const ray& r, hitable **WORLD, int depth) {
	ray cur_ray = r;
	glm::vec3 cur_attenuation(1.0, 1.0, 1.0);
	
	for (int i = 0; i < depth; i++) {
		hit_record rec;
		if ((*WORLD)->hit(cur_ray, 0.001, FLT_MAX, rec)) {
			ray scattered;
			glm::vec3 attenuation;
			if (rec.mat_ptr->scatter(cur_ray, rec, attenuation, scattered)) {
				cur_attenuation *= attenuation;
				cur_ray = scattered;
			}
			else {
				return glm::vec3(0.0, 0.0, 0.0);
			}
		}
		else {
			glm::vec3 unit_direction = glm::normalize(cur_ray.getDirection());
			float t = 0.5f*(unit_direction.y + 1.0f);
			glm::vec3 c = (1.0f - t)*glm::vec3(1.0, 1.0, 1.0) + t * glm::vec3(0.5, 0.7, 1.0);
			return cur_attenuation * c;
		}
	}
	return glm::vec3(0.0, 0.0, 0.0); // exceeded recursion

	/*
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
	*/
}

__global__ void initVariables(hitable **list, int list_length, hitable **WORLD) {
	if (threadIdx.x == 0 && blockIdx.x == 0) {
		list[0] = new sphere(glm::vec3( 0,	     0,	-1),		0.5,		new lambertian	(glm::vec3(0.8, 0.3, 0.3)));
		list[1] = new sphere(glm::vec3( 0,  -100.5, -1),		100,		new lambertian	(glm::vec3(0.8, 0.8, 0.0)));
		list[2] = new sphere(glm::vec3( 1,	     0,	-1),		0.5,		new metal		(glm::vec3(0.8, 0.6, 0.2),	0.3));
		list[3] = new sphere(glm::vec3(-1,	     0,	-1),		0.5,		new metal		(glm::vec3(0.8, 0.8, 0.8),	1.0));
		*WORLD = new hitable_list(list, list_length);
	}
}

__global__ void createImage(glm::vec3 *d_arr, hitable **WORLD, int _w, int _h, int ns) {
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int j = blockIdx.y * blockDim.y + threadIdx.y;
	
	if (i >= _w || j >= _h) return;
	
	glm::vec3 color(0,0,0);
	camera cam;
	ray r;

	for (int s = 0; s < ns; s++) {
		float u = float(i + UTIL_rand_d()) / float(_w);
		float v = float(j + UTIL_rand_d()) / float(_h);
		r = cam.getRay(u, v);
		color += getColor(r, WORLD, 50);
	}

	color /= float(ns);
	// color = glm::vec3(glm::sqrt(color.r), glm::sqrt(color.g), glm::sqrt(color.b));

	color.r = int(255.99 * color.r);
	color.g = int(255.99 * color.g);
	color.b = int(255.99 * color.b);
	
	// Llevar los resultados al array 
	int pos = j * _w + i;
	pos = abs(_w*_h - pos);
	// d_arr[pos] = glm::vec3(pos, pos, pos);
	d_arr[pos] = color;
}

int main(void) {
	//Establezco la GPU que voy a usar
	cudaSetDevice(0);
	
	// DATA 
	// ns es la precision del aliasing 
	const std::string filename = "img.PPM";
	int const TOTAL_HITABLES = 4;
	int _w, _h, ns;
	cudaError_t err_;

	std::ofstream _out(filename);
	_w = 200;
	_h = 100;
	ns = 100;
	int imgSize = _w * _h;
	
	// Definir variables que voy a usar en la GPU
	// Array de salida de cada color
	glm::vec3 *d_arr = NULL;
	glm::vec3 *h_arr = new glm::vec3[_w*_h];

	for (int i = 0; i < imgSize; i++) {
		h_arr[i] = glm::vec3(0,0,0);
	}

	hitable **list = NULL;
	hitable **WORLD = NULL;

	// Reservo memoria de la GPU
	int kMemBytes = sizeof(glm::vec3)*_w*_h;
	
	cudaMalloc((void**)&d_arr,	kMemBytes);
	cudaMalloc((void**)&list,	TOTAL_HITABLES*sizeof(hitable*));
	cudaMalloc((void**)&WORLD,  sizeof(hitable*));
	
	// Solo se lanza 1 nucleo ya que solo se va a hacer 1 vez
	initVariables <<< 1,1 >>> (list, TOTAL_HITABLES,WORLD);
	cudaDeviceSynchronize();

	// Miro errores
	err_ = cudaGetLastError();
	if (err_ != cudaSuccess) {
		std::cerr << "A: Error " << cudaGetErrorString(err_) << "\n";
	}

	// Defino el tamanyo de bloque y malla
	int K_THREADS_W	= 32;
	int K_THREADS_H	= 32;
	int K_BLOCKS_W	= ((float)_w / K_THREADS_W) > (_w / K_THREADS_W) ? (_w / K_THREADS_W) + 1 : (_w / K_THREADS_W);
	int K_BLOCKS_H	= ((float)_h / K_THREADS_H) > (_h / K_THREADS_H) ? (_h / K_THREADS_H) + 1 : (_h / K_THREADS_H);

	std::cout << "BLOQUE: " << K_THREADS_W << " x " << K_THREADS_H << std::endl;
	std::cout << "MALLA: " << K_BLOCKS_W << " x " << K_BLOCKS_H << std::endl;

	dim3 tpb(K_THREADS_W, K_THREADS_H, 1);	// Hilos por bloque		(THREADS PER BLOCK)
	dim3 bpg(K_BLOCKS_W, K_BLOCKS_H, 1);	// Bloques por malla	(BLOCKS PER GRID)
	
	// LINK STARTO!
	cudaMemcpy(d_arr, h_arr, kMemBytes, cudaMemcpyHostToDevice);
	// Miro errores
	err_ = cudaGetLastError();
	if (err_ != cudaSuccess) {
		std::cerr << "C: Error " << cudaGetErrorString(err_) << "\n";
	}

	createImage <<< bpg, tpb >>> (d_arr, WORLD, _w, _h, ns);
	// Miro errores
	err_ = cudaGetLastError();
	if (err_ != cudaSuccess) {
		std::cerr << "D: Error " << cudaGetErrorString(err_) << "\n";
	}

	cudaMemcpy(h_arr, d_arr, kMemBytes, cudaMemcpyDeviceToHost);
	
	// Miro errores
	err_ = cudaGetLastError();
	if (err_ != cudaSuccess) {
		std::cerr << "E: Error " << cudaGetErrorString(err_) << "\n";
	}

	// Inicio del archivo PPM
	_out << "P3\n" << _w << " " << _h << "\n255\n";
	
	// ESTO DEBE IR EN UNA FUNCION GLOBAL
	for (int i = 0; i < imgSize; i++) {
			_out << h_arr[i].r << " ";
			_out << h_arr[i].g << " ";
			_out << h_arr[i].b << "\n";
	}

	// Libero la GPU
	// TODO: 
	//		Liberar el espacio reservado de la gpu
	// delete h_arr;
	
	// cudaFree(d_arr);
	// cudaFree(list);
	// cudaFree(WORLD);
	
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
	// NOTA: Creo que ambas formas son válidas
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

	Después, ese array DEBE SER llevado, usando la CPU, al fichero de salida para tener la imagen final

OBSERVACIONES:
	Un hilo utiliza los mismos datos para computar el color que cualquier otro hilo que se lance -> MEMORIA COMPARTIDA?

COMO COJONES LO HE HECHO:
	Cambiar la estructura de las clases, porque no compila ^^
	Mover todo al .h
	Leer MUCHA documentación
	Nvidia GTX 660 -> 16 bloques/sm && 2048 hilos/sm (IMG DE 200x100!!!!)
		T_BLOQUE = 32x32
		T_MALLA = 200/32 x 100/32 = 6.25x3.125 = 7x4

	---
	Hay un error y como da en la primera posicion de todas, sale de la funcion directamente y no hace nada

PASOS:
	1. Reservar la GPU y la memoria a usar
	2. Organizar bloques e hilos
	3. Llamada a funcion/es
	4. Liberacion de la memoria y la GPU
*/
// https://devblogs.nvidia.com/accelerated-ray-tracing-cuda/
// --------------------------------------------