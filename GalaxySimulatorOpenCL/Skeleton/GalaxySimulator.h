#include <iostream>
#include <vector>

#include <stdio.h>
#include <time.h>
#include <random>
#include <math.h>
#include <string>
#include <omp.h>
#include <list>
#include <tuple>
#include "intersection.h"

struct Body
{
	double x, y;		// 100 000km
	double vx, vy;		// 100 000km / 0.1nap
	int mass;			// 10^24 kg

	Body& operator=(const Body& other) {
		x = other.x;
		y = other.y;
		vx = other.vx;
		vy = other.vy;
		mass = other.mass;
		return *this;
	}
};

using namespace std;

const double PI = std::atan(1.0) * 4;
#define GravitationalConstant 0.498199486464 //6.67384*10^-11 m^3/kg*s^2 <=> 6.67384*10^-11 * (10^-8)^3 * 10^24 * (60*60*24)^2

const int InitialBodyCount = 3000;
const int SunMass = 2000000;
const int GiantPlanetMass = 2000;
const int PlanetMass = 6;
const int GiantPlanetCount = 100;
const double StandardDeviation = 0.3;
const double PlanetFreeZone = 500;
const int SpaceBorder = 1 << 14;

int BodyCount = InitialBodyCount;
Body space1[InitialBodyCount];
Body space2[InitialBodyCount];
bool currentSpace = 1;


inline bool outOfSpace(int coordinate)
{
	return coordinate <= -SpaceBorder || coordinate >= SpaceBorder;
}
inline bool outOfSpace(Body* body)
{
	return outOfSpace(body->x) || outOfSpace(body->y);
}
inline double minDistance(Body* a, Body* b)
{
	return 5 * min(ceil((a->mass + b->mass) / 100.0), 50.0);
}

void InitializeSpace()
{
	srand(time(0));
	random_device rd;
	mt19937 e2(rd());
	normal_distribution<double> normalDistribution(0.0, StandardDeviation);
	uniform_real_distribution<double> angleDistribution(0, 2 * PI);

	Body* space = space1;

	space[0].mass = SunMass;
	space[0].x = 0;
	space[0].y = 0;
	space[0].vx = 0;
	space[0].vy = 0;
	space2[0] = space[0];

	for (int i = 1; i < BodyCount; i++)
	{
		//calculate position
		double r, fi;
		do {
			r = abs(normalDistribution(e2))*SpaceBorder + PlanetFreeZone;
			fi = angleDistribution(e2);
			space[i].x = r*cos(fi);
			space[i].y = r*sin(fi);
		} while (outOfSpace(space + i));

		//calculate velocity
		double fiNormal = fi + PI / 2 + 0.1*normalDistribution(e2);
		double vk = sqrt(GravitationalConstant*SunMass / r)*(1 + normalDistribution(e2));
		space[i].vx = vk*cos(fiNormal);
		space[i].vy = vk*sin(fiNormal);

		//calculate mass
		if (i < 1 + GiantPlanetCount)
			space[i].mass = GiantPlanetMass*(1 + 0.5*normalDistribution(e2));
		else
			space[i].mass = PlanetMass*(1 + 0.5*normalDistribution(e2));

		if (space[i].vx == 0 && space[i].vy == 0)
			throw "Not enough speed";
		if (outOfSpace(space + i))
			throw "Out of space";

		space2[i] = space[i];
	}
}

void CheckCollusion()
{
	Body* space = currentSpace ? space1 : space2;
	Body* prevSpace = currentSpace ? space2 : space1;
	for (int i = 0; i < BodyCount - 1; i++)
	{
		Body* a = space + i;
		Body* a0 = prevSpace + i;
		if (a->mass >= 0)
		{
			int mass_sum = 0;
			double vxMmass_sum = 0.0;
			double vyMmass_sum = 0.0;
			#pragma omp parallel shared(mass_sum, vxMmass_sum, vyMmass_sum) 
			{
			 #pragma omp for schedule(static) reduction(+:mass_sum, vxMmass_sum, vyMmass_sum)
			 for (int k = i + 1; k < BodyCount; k++)
			 {
				Body* b = space + k;
				Body* b0 = prevSpace + k;
				if (b->mass >= 0)
				{
					double dx = b->x - a->x;
					double dy = b->y - a->y;
					double dist = sqrt(dx*dx + dy*dy);
					if (dist <= minDistance(a, b) || doIntersect({ a0->x, a0->y }, { a->x, a->y }, { b0->x, b0->y }, { b->x, b->y }))
					{
						mass_sum += b->mass;
						vxMmass_sum += b->mass*b->vx;
						vyMmass_sum += b->mass*b->vy;
						b->mass = -1;
					}
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
}

void ReplaceDeleted()
{
	Body* space = currentSpace ? space1 : space2;
	Body* prevSpace = currentSpace ? space2 : space1;
	
	for (int i = BodyCount - 1; i >= 0; i--)
	{
		if (space[i].mass < 0)
		{
			if (i != BodyCount - 1)
				std::swap(space[i], space[BodyCount - 1]);
			BodyCount--;
		}
	}
}

template <typename SimluateStrategy>
int SimulateDay()
{
	Body* space = currentSpace ? space1 : space2;
	Body* nextSpace = currentSpace ? space2 : space1;
	SimluateStrategy::simulateDay(space, nextSpace);
	currentSpace = !currentSpace;
	//ReplaceDeleted();
	CheckCollusion();
	ReplaceDeleted();
	return 0;
}

struct SimulateWithOpenMPStrategy 
{
	static void simulateDay(Body* space, Body* nextSpace)
	{
		#pragma omp parallel for
		for (int i = 0; i < BodyCount; i++)
		{
			Body* b2 = space + i;
			Body* b = nextSpace + i;
			double ax_sum = 0.0;
			double ay_sum = 0.0;
			//#pragma omp parallel shared(ax_sum, ay_sum) 
			//{
			 //#pragma omp for schedule(static) reduction(+:ax_sum, ay_sum)
			 for (int k = 0; k < BodyCount; k++)
			 {
				Body* b1 = space + k;
				if (i != k)
				{
					double dx = b2->x - b1->x;
					double dy = b2->y - b1->y;
					double dist2 = dx*dx + dy*dy;
					double dist = sqrt(dist2);
					double a = (double)b1->mass / dist2;
					double ax = a * (dx / dist);
					double ay = a * (dy / dist);

					ax_sum += ax;
					ay_sum += ay;
				}
			 }
			//}

			double ax = -GravitationalConstant * ax_sum;
			double ay = -GravitationalConstant * ay_sum;

			b->x = b2->x + b2->vx;
			b->y = b2->y + b2->vy;
			b->vx = b2->vx + ax;
			b->vy = b2->vy + ay;
			if (i > 0  && b->vx == 0 && b->vy == 0)
				throw "Not enough speed";
			if (outOfSpace(b))
				b->mass = -1;
			else
				b->mass = b2->mass;
		}
	}
};

template <typename SimluateStrategy = SimulateWithOpenMPStrategy>
void simulateGalaxy(double days = 365)
{
	time_t start = time(0);

	FILE* fp;// = fopen("timeline.dat", "wb");
	fopen_s(&fp, "timeline.dat", "wb");
	fwrite(&InitialBodyCount, sizeof(int), 1, fp);
	try
	{
		InitializeSpace();
		CheckCollusion();
		//cout << CurrentBodyCount() << endl;

		int prevPercentage = -5;
		for (int n = 0; n < days; n++)
		{
			SimulateDay<SimluateStrategy>();
			Body* space = currentSpace ? space1 : space2;
			if (space[0].mass < 0)
				throw "Sun is out of it's place";
			for (int i = 0; i < BodyCount; i++)
			{
				Body* body = space + i;
				if (body->mass < 0)
					throw "Mass order error 1";
				int x = body->x, y = body->y;
				fwrite(&x, sizeof(int), 1, fp);
				fwrite(&y, sizeof(int), 1, fp);
				fwrite(&body->mass, sizeof(int), 1, fp);
			}
			for (int i = BodyCount; i < InitialBodyCount; i++)
			{
				//if (space[i].mass >= 0)
				//	throw "Mass order error 2";
				static const int negative = -1;
				fwrite(&negative, sizeof(int), 1, fp);
				fwrite(&negative, sizeof(int), 1, fp);
				fwrite(&negative, sizeof(int), 1, fp);
			}
			int percentage = n * 100 / days;
			if (prevPercentage / 5 != percentage / 5)
			{
				//cout << CurrentBodyCount() << endl;
				cout << percentage << "%" << endl;
				prevPercentage = percentage;
			}
		}

		cout << "Done in " << time(0) - start << " seconds" << endl;
	}
	catch (char* message)
	{
		cout << message << endl;
	}
	fclose(fp);
}

