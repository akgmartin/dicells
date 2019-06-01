# dicells
Cell Library for Delay Insensitive Synchronous Hardware

This library has been in use for several years, and has evolved over that time. It's definitely time for an overhaul, with better naming, documentation etc. I'll work on this as I can in the next few months.

Also, it needs a verification infrastructure so that changes can be made easily with confidence that nothing was broken. Ideally, I'd like to see an automated FV process. I'm open to suggestions, but I'm thinking hard about using ACL2, mostly because I think, with work, it could handle the Verilog parameterization in a nice way.

## Examples
The following repository contains a design using the cell library:
- [multi-stream-buffer](https://github.com/ytbmulder/multi-stream-buffer)
