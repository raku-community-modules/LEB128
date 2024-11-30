[![Actions Status](https://github.com/raku-community-modules/LEB128/actions/workflows/linux.yml/badge.svg)](https://github.com/raku-community-modules/LEB128/actions) [![Actions Status](https://github.com/raku-community-modules/LEB128/actions/workflows/macos.yml/badge.svg)](https://github.com/raku-community-modules/LEB128/actions) [![Actions Status](https://github.com/raku-community-modules/LEB128/actions/workflows/windows.yml/badge.svg)](https://github.com/raku-community-modules/LEB128/actions)

NAME
====

LEB128 - Encoding and decoding of integers in the LEB128 encoding

SYNOPSIS
========

```raku
use LEB128;

my $buf-eu = encode-leb128-unsigned(1234);
my $buf-es = encode-leb128-signed(-1234);
```

DESCRIPTION
===========

[LEB128 or Little Endian Base 128](https://en.wikipedia.org/wiki/LEB128) is a variable-length encoding of integers - that is, it aims to store integers of different sizes efficiently. It is used in the DWARF debug information format, Web Assembly, and other formats and protocols. This Raku module provides both encoding and decoding.

Encoding
========

There are both signed and unsigned encoding functions, `encode-leb128-signed` and `encode-leb128-unsigned` respectively. Both are `multi`s with candidates that take an `Int` and return a `Buf` with the encoded value:

```raku
my $buf-eu = encode-leb128-unsigned(1234);
my $buf-es = encode-leb128-signed(-1234);
```

Or to write the encoded `Int` into a `Buf` and return the number of bytes written, which is often more efficient since it avoids the creation of a temporary `Buf`:

```raku
my $buf = Buf.new;
my $offset = 0;
$offset += encode-leb128-unsigned(1234, $buf, $offset);
```

Decoding
========

There are both signed and unsigned decoding functions, `decode-leb128-signed` and `decode-leb128-unsigned` respectively. Both are `multi`s with candidates that take a `Buf` and try to decode an `Int` from the start of it, returning that `Int`:

```raku
my $value-du = decode-leb128-unsigned($entire-buffer-u);
my $value-ds = decode-leb128-signed($entire-buffer-s);
```

Or that decode the value from a specified offset in a given buffer, and use an `rw` parameter of type `int`, which is incremented by the number of bytes consumed.

```raku
my int $read;
my $value = decode-leb128-unsigned($buffer, $offset, $read);
```

To have the offset updated, it may be passed as both parameters:

```raku
my $value = decode-leb128-unsigned($buffer, $offset, $offset);
```

Method reference
================

### multi sub encode-leb128-signed

```raku
multi sub encode-leb128-signed(
    Int $value is copy,
    Buf $target,
    int $offset = 0
) returns int
```

Encodes the provided signed value into the target buffer at the given offset, returning the number of bytes produced.

### multi sub encode-leb128-signed

```raku
multi sub encode-leb128-signed(
    Int $value
) returns Buf
```

Encodes the provided signed value into a C<Buf> and returns it.

### multi sub encode-leb128-unsigned

```raku
multi sub encode-leb128-unsigned(
    Int $value is copy,
    Buf $target,
    int $offset = 0
) returns int
```

Encodes the provided unsigned value into the target buffer at the

### multi sub encode-leb128-unsigned

```raku
multi sub encode-leb128-unsigned(
    Int $value
) returns Buf
```

Encodes the provided unsigned value into a C<Buf> and returns it.

class X::LEB128::Incomplete
---------------------------

This exception is thrown if LEB128 decoding fails due to there being an incomplete value at the end of the buffer.

### multi sub decode-leb128-unsigned

```raku
multi sub decode-leb128-unsigned(
    Buf $encoded,
    int $offset is copy,
    int $read is rw
) returns Mu
```

Decodes an unsigned value from the provided buffer starting at the specified offset. The final rw parameter is incremented for each byte consumed from the buffer. Throws X::LEB128::Incomplete if a complete value cannot be read.

### multi sub decode-leb128-unsigned

```raku
multi sub decode-leb128-unsigned(
    Buf $encoded
) returns Int
```

Decodes the provided C<Buf> and returns the resulting unsigned value. Throws X::LEB128::Incomplete if a complete value cannot be read.

### multi sub decode-leb128-signed

```raku
multi sub decode-leb128-signed(
    Buf $encoded,
    int $offset is copy,
    int $read is rw
) returns Mu
```

Decodes a signed value from the provided buffer starting at the specified offset. The final rw parameter is incremented for each byte consumed from the buffer. Throws X::LEB128::Incomplete if a complete value cannot be read.

### multi sub decode-leb128-signed

```raku
multi sub decode-leb128-signed(
    Buf $encoded
) returns Int
```

Decodes the provided C<Buf> and returns the resulting signed value. Throws X::LEB128::Incomplete if a complete value cannot be read.

AUTHOR
======

Jonathan Worthington

COPYRIGHT AND LICENSE
=====================

Copyright 2020 - 2024 Jonathan Worthington

Copyright 2024 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

