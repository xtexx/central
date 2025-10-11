#include <bits/stdc++.h>

int main() {
    char a[1024];
    scanf("%s\n", a);
    char b;
    int c=0;
    while((b = getchar()) != EOF) {
        //if (b == '0') c = 0;
        if (b == '1') c++;
        getchar();
    }
    printf("%d\n", c);
    return 0;
}

