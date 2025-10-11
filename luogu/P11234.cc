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
#define TRYSKIP()                                       \
    if ((clock() - clkstart) > (CLOCKS_PER_SEC * 0.95)) \
        skipppp = true;

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

    // static clock_t clkstart;
    // static bool skipppp = false;

    uint bitsof(uint v)
    {
        uint ret = 0;
        while (v != 0)
        {
            v >>= 1;
            ++ret;
        }
        return ret - 1;
    }

#define twoof(a) (1 << a)

#define MAXN 100005
#define MAXM 100005
#define MAXK 17      // bitsof(100005) + 1
#define MAX2K 131072 // twoof(17)
#define MAXA ((1 << 31) - 1)

    static uint n, m, K;
    static uint ap[MAXN];
    static uint a[MAXN];
    static uint c[MAXM];
    static uint X[4];
    static uint d[MAXK][MAX2K];

    static uint mbr[MAXN];
    // static uint ar[MAXN];

    ull sol3(uint q)
    {
        // 剩余比赛轮数
        uint koq = bitsof(q);
        // 剩余人数
        uint cnt = twoof(koq);
        for (uint i = 0; i < cnt; ++i)
            mbr[i] = i;
        for (uint i = 0; i < koq; ++i)
        {
            // 模拟比赛
            uint *di = d[i];
            cnt >>= 1;
            for (uint r = 0; r < cnt; ++r)
            {
                // 模拟场次，mbr[r*2] 对 mbr[(r*2)+1]
                uint m1 = mbr[r * 2];
                uint m2 = mbr[(r * 2) + 1];
                if (di[r])
                {
                    // 后者为擂主
                    if ((m2 < q ? a[m2] : 0) > i)
                        mbr[r] = m2;
                    else
                        mbr[r] = m1;
                }
                else
                {
                    // 前者为擂主
                    if ((m1 < q ? a[m1] : 0) > i)
                        mbr[r] = m1;
                    else
                        mbr[r] = m2;
                }
            }
        }
        return mbr[0] + 1;
    }

    ull sol2(uint q)
    {
        ull a0 = sol3(q);
        ull ans = a0;
        uint koq = bitsof(q);
        uint cnt = twoof(koq);
        // for (uint i = q + 1; i <= cnt; ++i)
        // {
        //     if (i != a0)
        //         ans += i;
        // }
        return ans;
    }

    void sol1()
    {
        ull ans = 0ll;
        for (uint i = 0; i < n; ++i)
            a[i] = ap[i] ^ X[i % 4];
        for (uint i = 1; i <= m; ++i)
        {
            // printf("V %u * %llu\n", i, sol2(c[i]));
            ans ^= (sol2(c[i]) * i);
        }
        printf("%llu\n", ans);
    }

    void sol()
    {
        UINTTO(n);
        UINTTO(m);
        for (uint i = 0; i < n; ++i)
            UINTTO(ap[i]);
        for (uint i = 1; i <= m; ++i)
            UINTTO(c[i]);
        K = bitsof(n);
        uint cnt = twoof(K);
        for (uint i = 0; i <= K; ++i)
        {
            uint *dk = d[i];
            for (uint j = 0; j < cnt; ++j)
                dk[j] = (getchar() & 1);
            if (getchar() == '\r')
                getchar();
            cnt >>= 1;
        }

        GETUINT(T);
        for (uint i = 0; i < T; ++i)
        {
            UINTTO(X[3]);
            UINTTO(X[0]);
            UINTTO(X[1]);
            UINTTO(X[2]);
            sol1();
        }
    }
}

int main()
{
    std::ios::sync_with_stdio(false);
    std::cin.tie(nullptr);
    //freopen("arena.in", "r", stdin);
    //freopen("arena.out", "w", stdout);
    // xtex::clkstart = clock();
    xtex::sol();
    return 0;
}

/**
 * 17:27
 */

