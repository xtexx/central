var REG_NONE = NewRegistrar("none");

var DSP_BIND = NewDnsProvider("bind");
var DSP_DESEC = NewDnsProvider("desec");
var DSP_GCORE = NewDnsProvider("gcore");
var DSP_CF = NewDnsProvider("cf");

DEFAULTS(CF_PROXY_DEFAULT_OFF);

require("converted/xvnet0.eu.org.js");
D_EXTEND("xvnet0.eu.org", DnsProvider(DSP_DESEC, 0));

require("converted/xvnet.eu.org.js");
D_EXTEND("xvnet.eu.org", DnsProvider(DSP_GCORE, 0));

require("converted/xvnetstatus.us.kg.js");
D_EXTEND("xvnetstatus.us.kg", DnsProvider(DSP_DESEC, 0));

// var domains = getConfiguredDomains();
// for (i = 0; i < domains.length; i++)
// 	D_EXTEND(domains[i], DnsProvider(DSP_BIND));
