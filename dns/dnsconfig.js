var DSP_CLOUDFLARE = NewDnsProvider("cloudflare");
var REG_NONE = NewRegistrar("none");

D("xtexx.eu.org", REG_NONE,
	DnsProvider(DSP_CLOUDFLARE),
	DefaultTTL(1),
	CNAME("@", "e13f334e-0190-427e-8ed0-4a6d354f5080.cfargotunnel.com.", CF_PROXY_ON),
	MX("@", 65, "route3.mx.cloudflare.net."),
	MX("@", 70, "route2.mx.cloudflare.net."),
	MX("@", 16, "route1.mx.cloudflare.net."),
	CNAME("blog", "e13f334e-0190-427e-8ed0-4a6d354f5080.cfargotunnel.com.", CF_PROXY_ON),
	CNAME("serpo-b3168d6732d5", "6045d315-3d3e-41af-8065-e3c567691be1.cfargotunnel.com.", CF_PROXY_ON),
	CNAME("upptime", "cname.vercel-dns.com."),
	CNAME("uptime", "e13f334e-0190-427e-8ed0-4a6d354f5080.cfargotunnel.com.", CF_PROXY_ON),
	TXT("_dmarc", "v=DMARC1;  p=none; rua=mailto:eb9240254e2742039ffb9221e8201ef6@dmarc-reports.cloudflare.net"),
	TXT("@", "v=spf1 include:_spf.mx.cloudflare.net ~all"),
);

D("xtexx.us.kg", REG_NONE,
	DnsProvider(DSP_CLOUDFLARE),
);

D("yjyz.us.kg", REG_NONE,
	DnsProvider(DSP_CLOUDFLARE),
	DefaultTTL(1),
	CNAME("@", "codeberg.page."),
	CNAME("sp", "6045d315-3d3e-41af-8065-e3c567691be1.cfargotunnel.com.", CF_PROXY_ON),
	MX("@", 80, "route3.mx.cloudflare.net."),
	MX("@", 70, "route2.mx.cloudflare.net."),
	MX("@", 20, "route1.mx.cloudflare.net."),
	TXT("@", "\"yjyz-tools.xtex.codeberg.page\""),
	TXT("@", "\"v=spf1 include:_spf.mx.cloudflare.net ~all\""),
);

D("hgdns.ren", REG_NONE,
	DnsProvider(DSP_CLOUDFLARE),
	DefaultTTL(1),
	CNAME("@", "opilio.s.xvnet0.eu.org.", CF_PROXY_ON),
	MX("@", 72, "route3.mx.cloudflare.net."),
	MX("@", 31, "route2.mx.cloudflare.net."),
	MX("@", 60, "route1.mx.cloudflare.net."),
	TXT("_dmarc", "\"v=DMARC1; p=none; rua=mailto:e53d706fcb814df8bffa119e207a0dec@dmarc-reports.cloudflare.net\""),
	TXT("_github-pages-challenge-yjyz-flcc", "b30dfd14b9add662c2209afb72c8c8"),
	TXT("@", "google-site-verification=_EnDo3sv6eXlKHwSyzkcDUtvqWw718D0tfkMJTPkM30", TTL(3600)),
	TXT("@", "\"v=spf1 include:_spf.mx.cloudflare.net ~all\""),
);
