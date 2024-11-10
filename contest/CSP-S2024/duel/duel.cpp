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
    freopen("duel.in", "r", stdin);
    freopen("duel.out", "w", stdout);
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

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
RXDQ3rHEZ/sCAAAAAARZWg==

 */
