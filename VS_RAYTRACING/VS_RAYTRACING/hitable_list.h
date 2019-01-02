#pragma once

#include "Util.h"
#include "hitable.h"

class hitable_list : public hitable {
	private:
		hitable **list;
		int list_size;

	public:
		hitable_list();
		~hitable_list();
		hitable_list(hitable**, int);
		virtual bool hit(const ray&, float, float, hit_record&) const;
};