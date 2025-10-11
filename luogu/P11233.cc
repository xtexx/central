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

namespace xtex
{
    using namespace std;

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

    uint rdint()
    {
        uint v = 0;
        int s = 1;
        char ch = getchar();
        while (ch < '0' || ch > '9')
        {
            if (ch == '-')
                s = -1;
            ch = getchar();
        }
        while (ch >= '0' && ch <= '9')
        {
            v = (v << 3) + (v << 1) + (ch ^ '0');
            ch = getchar();
        }
        return s * v;
    }

#define MAXN 200010
#define MAXA 1000005

    static uint n;
    static uint a[MAXN];
    static bool c[MAXN];

    static clock_t clkstart;
    static bool skipppp = false;

    uint search(uint depth)
    {
        if (EXP(depth != n, 1))
        {
            if (skipppp)
                return 0;
            uint ans;
            c[depth] = false;
            ans = search(depth + 1);
            c[depth] = true;
            ans = max(ans, search(depth + 1));
            if ((clock() - clkstart) > (CLOCKS_PER_SEC * 0.95))
                skipppp = true;
            return ans;
        }
        else
        {
            uint ans = 0;
            uint last[2] = {0x3f3f3f3f, 0x3f3f3f3f};
            for (uint i = 0; i < n; ++i)
            {
                uint av = a[i];
                bool cv = c[i];
                if (EXP(last[cv] == av, 0))
                {
                    ans += av;
                }
                else
                {
                    last[cv] = av;
                }
            }
            return ans;
        }
    }

    void sol()
    {
        UINTTO(n);
        memset(a, 0, sizeof(uint[n]));
        memset(c, 0, sizeof(bool[n]));
        // uint maxa = 0, mina = MAXA;
        for (uint i = 0; i < n; ++i)
        {
            GETUINT(av);
            a[i] = av;
            // maxa = max(maxa, av);
            // mina = min(mina, av);
        }
        uint ans = search(0);
        printf("%u\n", ans);
    }
}

int main()
{
    std::ios::sync_with_stdio(false);
    std::cin.tie(nullptr);
    //freopen("color.in", "r", stdin);
    //freopen("color.out", "w", stdout);
    xtex::clkstart = clock();
    GETUINT(T);
    for (uint i = 0; EXP(i < T, 1); ++i)
        xtex::sol();
    return 0;
}

/**
 * 17:11
 */

