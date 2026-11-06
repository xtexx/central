.PHONY: stable fmt

stable:
	git update-ref refs/heads/stable refs/heads/main
	git push origin stable:stable --force

fmt:
	pnpx prettier --write '.'
