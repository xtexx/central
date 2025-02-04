#include <bits/stdc++.h>

int fastread() {
  int x = 0, w = 1;
  char ch = getchar();
  if (ch == '-') {
    w = -1;
    ch = getchar();
  }
  while (ch >= '0' && ch <= '9') {
    x = (x << 3) + (x << 1) + (ch ^ '0');
    ch = getchar();
  }
  return x * w;
}

int main() {
  std::ios::sync_with_stdio(false);
  std::cin.tie(0);
  unsigned int T = (unsigned int)fastread();
  for (unsigned int i = 0; i < T; ++i) {
    printf("0\n");
  }
  return 0;
}
