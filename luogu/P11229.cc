#include <bits/stdc++.h>

int main() {
  using namespace std;
  cin.tie(0);
  ios::sync_with_stdio(false);
  int t;
  scanf("%d", &t);
  while (t--) {
    int n;
    scanf("%d", &n);
    switch (n % 7) {
    case 0:
      break;
    case 1: {
      if (n == 1) {
        printf("-1\n");
        continue;
      }
      n -= 8;
      printf("10");
      break;
    }
    case 2: {
      n -= 2;
      putchar('1');
      break;
    }
    case 3: {
      if (n == 3) {
        printf("7\n");
        continue;
      } else if (n == 10) {
        printf("22\n");
        continue;
      }
      n -= 17;
      printf("200");
      break;
    }
    case 4: {
      if (n == 4) {
        printf("4\n");
        continue;
      }
      n -= 11;
      printf("20");
      break;
    }
    case 5: {
      n -= 5;
      printf("2");
      break;
    }
    case 6: {
      n -= 6;
      printf("6");
      break;
    }
    }
    int k = n / 7;
    for (int i = 0; i < k; ++i)
      putchar('8');
    putchar('\n');
  }
  return 0;
}
