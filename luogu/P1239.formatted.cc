#include <bits/stdc++.h>
#define uint unsigned int
using namespace std;

int main() {
  char n[15];
  char ch;
  uint l = 0;
  uint N = 0;
  while (isdigit(ch = getchar())) {
    n[l++] = ch;
    N = (N << 3) + (N << 1) + (ch ^ '0');
  }
  for (uint d = 0; d < 10; ++d) {
    uint ans = 0;
    uint j = 1;
    for (uint i = 0; i < l; ++i) {
      // digit d in pos i
      j = (j << 3) + (j << 1);
      uint masked = N % j;
      if (n[i] >= d)
        ++ans;
      uint unm = N - masked;
      ans += (unm / j);
    }
    if (d == 0)
      --ans;
    printf("%u\n", ans);
  }
  return 0;
}
