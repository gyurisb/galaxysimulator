#pragma OPENCL EXTENSION cl_khr_fp64 : enable
#pragma OPENCL EXTENSION cl_khr_int64_base_atomics : enable
#pragma OPENCL EXTENSION cl_khr_int64_extended_atomics : enable

#define GravitationalConstant 0.498199486464 //6.67384*10^-11 m^3/kg*s^2 <=> 6.67384*10^-11 * (10^-8)^3 * 10^24 * (60*60*24)^2û
#define SpaceBorder 1 << 14

typedef struct Body
{
	double x, y;		// 100 000km
	double vx, vy;		// 100 000km / 0.1nap
	int mass;			// 10^24 kg
} Body;

__kernel void move(__global Body* space, __global Body* nextSpace, const int BodyCount)
{
	int i = get_global_id(0);
	if (i >= BodyCount)
		return;

	__global Body* b2 = space + i;
	__global Body* b = nextSpace + i;
	double b2x = b2->x;
	double b2y = b2->y;
	double ax_sum = 0.0;
	double ay_sum = 0.0;
	for (int k = 0; k < BodyCount; k++)
	{
		if (i != k)
		{
			__global Body* b1 = space + k;
			double dx = b2x - b1->x;
			double dy = b2y - b1->y;
			double dist2 = dx*dx + dy*dy;
			double dist = sqrt(dist2);
			double a = (double)b1->mass / dist2;
			double ax = a * (dx / dist);
			double ay = a * (dy / dist);

			ax_sum += ax;
			ay_sum += ay;
		}
	}

	double ax = -GravitationalConstant * ax_sum;
	double ay = -GravitationalConstant * ay_sum;

	b->x = b2x + b2->vx;
	b->y = b2y + b2->vy;
	b->vx = b2->vx + ax;
	b->vy = b2->vy + ay;
	if (b->x <= -SpaceBorder || b->x >= SpaceBorder || b->y <= -SpaceBorder || b->y >= SpaceBorder)
		b->mass = -1;
	else
		b->mass = b2->mass;
}

__kernel void checkCollusion(__global Body* prevSpace, __global Body* space, const int BodyCount)
{
	int i = get_global_id(0);
	if (i >= BodyCount)
		return;

	__global Body* a = space + i;
	__global Body* a0 = prevSpace + i;
	if (a->mass >= 0)
	{
		int mass_sum = 0;
		double vxMmass_sum = 0.0;
		double vyMmass_sum = 0.0;
		for (int k = i + 1; k < BodyCount; k++)
		{
			__global Body* b = space + k;
			__global Body* b0 = prevSpace + k;
			if (b->mass >= 0)
			{
				double dx = b->x - a->x;
				double dy = b->y - a->y;
				double dist = sqrt(dx*dx + dy*dy);
				if (dist <= 5*min(ceil((a->mass + b->mass) / 100.0), 50.0))
				{
					mass_sum += b->mass;
					vxMmass_sum += b->mass*b->vx;
					vyMmass_sum += b->mass*b->vy;
					b->mass = -1;
				}
			}
		}
		if (mass_sum > 0)
		{
			int newmass = a->mass + mass_sum;
			a->vx = (a->mass*a->vx + vxMmass_sum) / newmass;
			a->vy = (a->mass*a->vy + vyMmass_sum) / newmass;
			a->mass = newmass;
		}
	}
}


//__kernel void move(__global Body* space, __global Body* nextSpace, const int BodyCount) 
//{
//	int i = get_global_id(0);
//	if (i > BodyCount)
//		return;
//
//	__global Body* b2 = space + i;
//	__global Body* b = nextSpace + i;
//	double b2x = b2->x, b2y = b2->y, b2vx = b2->vx, b2vy = b2->vy;
//	double bx, by, bvx, bvy, bmass;
//
//	double ax_sum = 0.0;
//	double ay_sum = 0.0;
//	for (int k = 0; k < BodyCount; k++)
//	{
//		if (i != k)
//		{
//			__global Body* b1 = space + k;
//			double b1x = b1->x, b1y = b1->y, b1mass = b1->mass;
//
//			double dx = b2x - b1x;
//			double dy = b2y - b1y;
//			double dist2 = dx*dx + dy*dy;
//			double dist = sqrt(dist2);
//			double a = (double)b1mass / dist2;
//			double ax = a * (dx / dist);
//			double ay = a * (dy / dist);
//
//			ax_sum += ax;
//			ay_sum += ay;
//		}
//	}
//
//	double ax = -GravitationalConstant * ax_sum;
//	double ay = -GravitationalConstant * ay_sum;
//
//	bx = b2x + b2vx;
//	by = b2y + b2vy;
//	bvx = b2vx + ax;
//	bvy = b2vy + ay;
//	if (bx <= -SpaceBorder || bx >= SpaceBorder || by <= -SpaceBorder || by >= SpaceBorder)
//		bmass = -1;
//	else
//		bmass = b2->mass;
//
//	b->x = bx;
//	b->y = by;
//	b->vx = bvx;
//	b->vy = bvy;
//	b->mass = bmass;
//}

//enum BodyMember {
//	body_x = 0,
//	body_y = 1,
//	body_vx = 2,
//	body_vy = 3,
//	body_mass = 4,
//	body_member_count = 5
//};
//
//__kernel void move(__global double* space, __global double* nextSpace) {
//	int i = get_global_id(0);
//	int BodyCount = get_global_size(0);
//	__global double* b2 = space + i*body_member_count;
//	if (b2[body_mass] >= 0)
//	{
//		double ax_sum = 0.0;
//		double ay_sum = 0.0;
//		for (int k = 0; k < BodyCount; k++)
//		{
//			__global double* b1 = space + k*body_member_count;
//			if (i != k && b1[body_mass] >= 0)
//			{
//				double dx = b2[body_x] - b1[body_x];
//				double dy = b2[body_y] - b1[body_y];
//				double dist2 = dx*dx + dy*dy;
//				double dist = sqrt(dist2);
//				double a = (double)b1[body_mass] / dist2;
//				double ax = a * (dx / dist);
//				double ay = a * (dy / dist);
//
//				ax_sum += ax;
//				ay_sum += ay;
//			}
//		}
//
//		double ax = -GravitationalConstant * ax_sum;
//		double ay = -GravitationalConstant * ay_sum;
//
//		__global double* b = nextSpace + i*body_member_count;
//		b[body_x] = b2[body_x] + b2[body_vx];
//		b[body_y] = b2[body_y] + b2[body_vy];
//		b[body_vx] = b2[body_vx] + ax;
//		b[body_vy] = b2[body_vy] + ay;
//		/*if (b[body_x] <= -SpaceBorder || b[body_x] >= SpaceBorder || b[body_y] <= -SpaceBorder || b[body_x] >= SpaceBorder)
//		b[body_mass] = b2[body_mass] = -1;
//		else
//		b[body_mass] = b2[body_mass];*/
//	}
//}