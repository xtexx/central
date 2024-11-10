#include <bits/stdc++.h>

#define ui unsigned int

ui r() {
  ui v = 0;
  char ch = getchar();
  while (ch < '0' || ch > '9')
    ch = getchar();
  while (ch >= '0' && ch <= '9') {
    v = (v << 3) + (v << 1) + (ch ^ '0');
    ch = getchar();
  }
  return v;
}

#define MAXN 105

static ui a[MAXN][MAXN];
static ui p[MAXN];

int main() {
  using namespace std;
  ios::sync_with_stdio(false);
  cin.tie(0);
#ifndef ONLINE_JUDGE
  //	freopen("data.in", "r", stdin);
  //	freopen("data.out", "w", stdout);
#endif
  ui n = r();
  for (ui i = 1; i <= n; ++i) {
    ui di = r();
    ui *ai = a[i];
    for (ui j = 0; j < di; ++j)
      ai[j] = r();
  }
  ui m = r();
  for (ui i = 0; i < m; ++i) {
    ui sc = 0;
    for (ui j = 1; j <= n; ++j) {
      ui *pj = p + j;
      ui pv = r();
      for (ui *aj = a[j]; *aj != 0; ++aj)
        pv &= p[*aj];
      *pj = pv;
      if (pv)
        ++sc;
    }
    printf("%u\n", sc);
  }
  return 0;
}
