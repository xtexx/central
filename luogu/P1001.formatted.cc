#include <bits/stdc++.h>

int rdi() {
  int v = 0, s = 1;
  char ch = getchar();
  while (!isdigit(ch)) {
    if (ch == '-')
      s = -1;
    ch = getchar();
  }
  while (isdigit(ch)) {
    v = (v << 3) + (v << 1) + (ch ^ '0');
    ch = getchar();
  }
  return v * s;
}

int main() {
  using namespace std;
  ios::sync_with_stdio(false);
  cin.tie(0);
  int a = rdi();
  int b = rdi();
  printf("%d\n", a + b);
  return 0;
}
