#include <bits/stdc++.h>

static int crow[100005], ccol[100005], trow[100005], tcol[100005];

int rdi() {
	int v = 0;
	char ch = getchar();
	while (!(ch >= '0' && ch <= '9')) ch = getchar();
	while (ch >= '0' && ch <= '9') {
		v = (v << 3) + (v << 1) + (ch ^ '0');
		ch = getchar();
	}
	return v;
}

int main() {
    using namespace std;
    cin.tie(0); ios::sync_with_stdio(false);
    int T = 0; T = rdi();
    while (T --) {
    	memset(crow, 0, sizeof(crow));
    	memset(ccol, 0, sizeof(ccol));
    	memset(trow, 0, sizeof(trow));
    	memset(tcol, 0, sizeof(tcol));
	    int n,m,q; n = rdi(); m = rdi(); q = rdi();
	    for (int t = 1; t <= q; ++ t) {
	        int o, x, c; o = rdi(); x = rdi(); c = rdi();
	        if (o == 0) {
	        	crow[x] = c;
	        	trow[x] = t;
			} else {
	        	ccol[x] = c;
	        	tcol[x] = t;
			}
	    }
	    for (int x = 1; x <= n; ++ x) {
	    	int cr = crow[x], tr = trow[x];
	    	for (int y = 1; y <= m; ++ y) {
	    		int cc = ccol[y], tc = tcol[y];
	    		if (tr > tc) cc = cr;
	    		printf("%d ", cc);
			}
			putchar('\n');
		}
	}
    return 0;
}
