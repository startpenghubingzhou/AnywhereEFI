# AnywhereEFI

[![Build Status](https://travis-ci.org/yangsenlin/snsdemo.svg?branch=master)](https://travis-ci.org/yangsenlin/snsdemo)

AnywhereEFI is a useful command  for EFI management  in Hackintosh. It is overwritten from the sh version of AnywhereEFI written by me(the origin version has  been deleted now).



# Features



- EFI Mount
- Hackintosh bootloader updating(supported Clover and OpenCore for now)
- EFI Backup



# Usage

 

```
AnywhereEFI <-protocol [proxy]> <-url [proxyURL]>

```

`<-protocol [proxy]>:`  **Your proxy protocol for curl**(Using in EFI Update).

 `[proxy]` is your protocol(like socks, socks5...)

`<-url [proxyURL]>:`  **Your proxy URL**. 

`[proxyURL]` is your URL for proxy(including ports).



For more params, please use `curl --help`

# Credits

- [williambj1](https://github.com/williambj1) for [OpenCore-Factory](https://github.com/williambj1/OpenCore-Factory)
- [Dids](https://github.com/Dids) for [clover-builder](https://github.com/Dids/clover-builder)
- [startpenghubingzhou](https://github.com/startpenghubingzhou) for mantaining

