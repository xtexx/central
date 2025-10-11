// SPDX-License-Identifier: GPL-3.0-or-later
// Author: Bingwu Zhang <xtex@xtexx.eu.org>
// GD-S00860
#include <bits/stdc++.h>

#define uint unsigned int
#define ull unsigned long long
#define ll long long
#define EXP __builtin_expect
#define GETUINT(x) unsigned int x = ::xtex::rduint()

namespace xtex
{
    using namespace std;

#define MAXN 100005
#define MAXR 100005

    static uint rv[MAXR];

    uint rduint()
    {
        uint v = 0;
        char ch = getchar();
        while (ch < '0' || ch > '9')
            ch = getchar();
        while (ch >= '0' && ch <= '9')
        {
            v = (v << 3) + (v << 1) + (ch ^ '0');
            ch = getchar();
        }
        return v;
    }

    void sol()
    {
        GETUINT(n);
        uint mxr = 0;
        for (uint i = 0; i < n; ++i)
        {
            GETUINT(r);
            mxr = max(mxr, r);
            ++rv[r];
        }

        uint ans = 0;
        for (uint i = 1; i <= mxr; ++i)
        {
            uint count = rv[i];
            if (EXP(count == 0, 1))
                continue;
            // go attack!
            uint killed = min(ans, count);
            ans -= killed;
            // be attacked!
            ans += count;
        }

        printf("%u\n", ans);
    }
}

int main()
{
    std::ios::sync_with_stdio(false);
    std::cin.tie(nullptr);
    //freopen("duel.in", "r", stdin);
    //freopen("duel.out", "w", stdout);
    xtex::sol();
    return 0;
}

/**
30 mins AC

noi@noi-vm:/mnt/hgfs/gd/duel$ ../testall.sh duel
duel.cpp: In function ‘int main()’:
duel.cpp:64:12: warning: ignoring return value of ‘FILE* freopen(const char*, const char*, FILE*)’, declared with attribute warn_unused_result [-Wunused-result]
   64 |     freopen("duel.in", "r", stdin);
      |     ~~~~~~~^~~~~~~~~~~~~~~~~~~~~~~
duel.cpp:65:12: warning: ignoring return value of ‘FILE* freopen(const char*, const char*, FILE*)’, declared with attribute warn_unused_result [-Wunused-result]
   65 |     freopen("duel.out", "w", stdout);
      |     ~~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~~
===== ../../c/duel/duel1.ans

real	0m0.007s
user	0m0.002s
sys	0m0.000s
===== ../../c/duel/duel2.ans

real	0m0.008s
user	0m0.000s
sys	0m0.003s
===== ../../c/duel/duel3.ans

real	0m0.007s
user	0m0.003s
sys	0m0.000s
===== ../../c/duel/duel4.ans

real	0m0.010s
user	0m0.004s
sys	0m0.000s


 */

