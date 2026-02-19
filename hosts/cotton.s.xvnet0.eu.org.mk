### tiang::target cotton ssh://cotton.s.xvnet0.eu.org

XVNET_NUM := 3
DISTRO := aoscos

### tiang::tag cotton bird
$(call load-state, services/bird)

### tiang::tag cotton caddy
$(call load-state, services/caddy)
