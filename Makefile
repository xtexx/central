LEONIS_BASE_DIR = ./external/leonis
STATES_DIR = .
ATRE_DIR = /srv/atremis

define vendor-targets
$(eval include hosts/$(HOSTNAME).mk)
$(eval -include /srv/secrets/atre/$(HOSTNAME).mk)
$(call load-state, services/atremis)
endef

include $(LEONIS_BASE_DIR)/Makefile
