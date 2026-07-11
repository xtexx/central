function 0file; curl -F"file=@$argv" https://0x0.st; end
function 0pb; curl -F"file=@-;" https://0x0.st; end
function 0url; curl -F"url=$argv" https://0x0.st; end
function 0short; curl -F"shorten=$argv" https://0x0.st; end
