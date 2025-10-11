#include <bits/stdc++.h>
#define ull unsigned long long

ull readi() {
    ull v=0;
    char ch = getchar();
    while (!isdigit(ch)) ch = getchar();
    while (isdigit(ch)) {
        v = (v << 3) + (v << 1) + (ch ^ '0');
        ch = getchar();
    }
    return v;
}

ull a[100005];

int main() {
    using namespace std;
    ios::sync_with_stdio(false);
    cin.tie(0);
    ull i = readi();
    while (i) {
        i --;
        ull n = readi();
        for (ull m = 0; __builtin_expect(m < n,1); ++m) {
            a[m] = readi();
        }
        sort(a, a+n);
        ull tgt = 1, anyth = 0, mustak=0;
        for (ull m = 0; __builtin_expect(m < n,1); ++m) {
            ull am = a[m];
            if (am >= tgt) {
                mustak += am - tgt;
                ++tgt;
            } else {
                anyth += am - 1;
            }
        }
        if (mustak <= tgt && tgt <= (mustak + anyth)) ++tgt;
        printf("%llu\n", tgt);
    }
    return 0;
}
