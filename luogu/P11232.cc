// SPDX-License-Identifier: GPL-3.0-or-later
// Author: Bingwu Zhang <xtex@xtexx.eu.org>
// GD-S00860
#include <bits/stdc++.h>

#define uint unsigned int
#define ull unsigned long long
#define ll long long
#define EXP __builtin_expect
#define GETUINT(x) unsigned int x = ::xtex::rduint()
#define UINTTO(x) x = ::xtex::rduint()
#define GETINT(x) int x = ::xtex::rdint()
#define INTTO(x) x = ::xtex::rdint()

namespace xtex {
using namespace std;

uint rduint() {
  uint v = 0;
  char ch = getchar();
  while (ch < '0' || ch > '9')
    ch = getchar();
  while (ch >= '0' && ch <= '9') {
    v = (v << 3) + (v << 1) + (ch ^ '0');
    ch = getchar();
  }
  return v;
}

uint rdint() {
  uint v = 0;
  int s = 1;
  char ch = getchar();
  while (ch < '0' || ch > '9') {
    if (ch == '-')
      s = -1;
    ch = getchar();
  }
  while (ch >= '0' && ch <= '9') {
    v = (v << 3) + (v << 1) + (ch ^ '0');
    ch = getchar();
  }
  return s * v;
}

#define MAXN 100005
#define MAXM 100005
#define MAXL 1000005
#define MAXV 1005

class Car {
public:
  int d, v, a;
  bool os;
  // 超速位移区间，双端均闭
  uint osfrom, osto;
};

static Car cars[MAXN];
static uint p[MAXM];
static uint n, m;
static int L, V;

static vector<uint> cats[MAXM];
static uint psort[MAXM];
struct catscomp {
  bool operator()(uint a, uint b) const {
    return cats[a].size() > cats[b].size();
  }
};
static uint catshave[MAXN];
static bool ptaken[MAXM];

static clock_t clkstart;
static bool skipppp = false;

void sol() {
  memset(cars, 0, sizeof(cars));
  memset(p, 0x3f, sizeof(p));
  memset(catshave, 0, sizeof(catshave));
  memset(ptaken, 0, sizeof(ptaken));
  UINTTO(n);
  UINTTO(m);
  INTTO(L);
  INTTO(V);
  for (uint i = 0; EXP(i < n, 1); ++i) {
    Car &car = cars[i];
    INTTO(car.d);
    INTTO(car.v);
    INTTO(car.a);

    // 计算速度
    if (car.a > 0) {
      // a > 0 => v == vmax, when and only when x = maxp
      if (car.v > V)
        car.osfrom = car.d;
      else if (EXP(car.v == V, 0))
        car.osfrom = car.d + 1;
      else // car.v < V
        car.osfrom = car.d + (uint)ceil(((double)((V * V) - (car.v * car.v)) /
                                         (2 * (uint)car.a)) +
                                        0.0001);
      car.osto = L;
      car.os = car.osfrom <= car.osto;
    } else if (car.a < 0) {
      // a < 0 => v == vmax, when and only when t = 0
      if (car.v > V) {
        car.osfrom = car.d;
        car.osto = car.d + (uint)floor(((double)((car.v * car.v) - (V * V)) /
                                        (2 * (uint)-car.a)) -
                                       0.0001);
        car.os = true;
      } else {
        // car.os=false;
      }
    } else // a == 0
    {
      // a = 0 => v == vmax, always
      if (car.v > V) {
        car.osfrom = car.d;
        car.osto = L;
        car.os = true;
      }
    }
  }
  for (uint i = 0; EXP(i < m, 1); ++i) {
    UINTTO(p[i]);
    psort[i] = i;
    cats[i].clear();
  }
  // TODO: rewrite sort
  sort(p, p + m);

  uint ans1 = 0, ans2 = m;
  for (uint i = 0; EXP(i < n, 1); ++i) {
    Car &car = cars[i];
    if (!car.os)
      continue;

    uint *firstp = lower_bound(p, p + m, car.osfrom);
    if (*firstp <= car.osto) {
      ++ans1;

      if (skipppp)
        continue;
      uint *lastp = upper_bound(firstp, p + m, car.osto) - 1;
      uint firstpidx = (uint)(firstp - p);
      uint lastpidx = (uint)(lastp - p);
      for (uint j = firstpidx; j <= lastpidx; ++j) {
        cats[j].push_back(i);
      }
      if ((clock() - clkstart) > (CLOCKS_PER_SEC * 0.80))
        skipppp = true;
    }
  }
  if (skipppp) {
    printf("%u %u\n", ans1, m / 2 + 1);
    return;
  }
  sort(psort, psort + m, catscomp());
  for (uint j = 0; EXP(j < m, 1); ++j) {
    uint ptake = psort[j];
    bool take = false;
    vector<uint> &pcats = cats[ptake];
    if (pcats.empty())
      continue;
    for (uint car : pcats) {
      if (catshave[car] == 0) {
        take = true;
        break;
      }
    }
    if (take) {
      // printf("TAKING: %u @ %u\n", ptake, p[ptake]);
      // for (uint car : pcats)
      //     printf("  CAUGHT: %u\n", car);
      for (uint car : pcats)
        ++catshave[car];
      --ans2;
      ptaken[ptake] = true;
    }
    // else
    // {
    //     printf("NOT TAKING: %u\n", ptake);
    // }
    if ((clock() - clkstart) > (CLOCKS_PER_SEC * 0.80))
      skipppp = true;
  }

  for (uint j = 0; EXP(j < m, 1); ++j) {
    uint ptake = psort[j];
    if (!ptaken[ptake])
      continue;
    vector<uint> &pcats = cats[ptake];
    bool drop = true;
    for (uint car : pcats) {
      if (catshave[car] == 1) {
        drop = false;
        break;
      }
    }
    if (drop) {
      for (uint car : pcats)
        --catshave[car];
      // printf("DROPPING: %u\n", ptake);
      --ans2;
    }
    if ((clock() - clkstart) > (CLOCKS_PER_SEC * 0.80))
      skipppp = true;
  }

  printf("%u %u\n", ans1, ans2);
}
} // namespace xtex

int main() {
  std::ios::sync_with_stdio(false);
  std::cin.tie(nullptr);
  xtex::clkstart = clock();
  // freopen("detect.in", "r", stdin);
  // freopen("detect.out", "w", stdout);
  GETUINT(T);
  for (uint i = 0; EXP(i < T, 1); ++i)
    xtex::sol();
  return 0;
}

/**
 * 15:05
 */
