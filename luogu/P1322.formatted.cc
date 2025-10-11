#include <bits/stdc++.h>

inline int readInt(char &lc) {
  int v = 0;
  int s = 1;
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
  lc = ch;
  return v * s;
}

inline int execCmd() {
  int res = 0;
  while (true) {
    char lc;
    switch (lc = getchar()) {
    case 'F': {
      res += readInt(lc);
      break;
    }
    case 'B': {
      res -= readInt(lc);
      break;
    }
    case 'R': {
      int times = readInt(lc);
      res += (times * execCmd());
      break;
    }
    }
    if (lc == '\n' || lc == '\r' || lc == ']' || lc == EOF)
      break;
  }
  return res;
}

int main() {
  using namespace std;
  cin.tie(0);
  ios::sync_with_stdio(false);
  printf("%d\n", abs(execCmd()));
  return 0;
}
