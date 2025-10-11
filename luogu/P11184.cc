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

int main() {
    using namespace std;
    ios::sync_with_stdio(false);
    cin.tie(0);
    ull i = readi();
    while (i) {
        i --;
        ull n = readi(); ull k = readi();
        if (__builtin_expect(k == 0, 0)) {
            printf("1\n"); continue;
        }
        printf("%llu\n", (n/k)-(n/(k+1)));
    }
    return 0;
}

