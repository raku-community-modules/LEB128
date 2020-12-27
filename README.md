# LEB128

[LEB128 or Little Endian Base 128](https://en.wikipedia.org/wiki/LEB128)
is a variable-length encoding of integers - that is, it aims to store
integers of different sizes efficiently. It is used in the DWARF debug
information format, Web Assembly, and other formats and protocols. This
Raku module provides both encoding and decoding. 

## Encoding

There are both signed and unsigned encoding functions, `encode-leb128-signed`
and `encode-leb128-unsigned` respectively. Both are `multi`s with candidates
that take an `Int` and return a `Buf` with the encoded value:

    my $buf-eu = encode-leb128-unsigned(1234);
    my $buf-es = encode-leb128-signed(-1234);

Or to write the encoded `Int` into a `Buf` and return the number of bytes
written, which is often more efficient since it avoids the creation of a
temporary `Buf`:

    my $buf = Buf.new;
    my $offset = 0;
    $offset += encode-leb128-unsigned(1234, $buf, $offset);

## Decoding

There are both signed and unsigned decoding functions, `decode-leb128-signed`
and `decode-leb128-unsigned` respectively. Both are `multi`s with candidates
that take a `Buf` and try to decode an `Int` from the start of it, returning
that `Int`:

    my $value-du = decode-leb128-unsigned($entire-buffer-u);
    my $value-ds = decode-leb128-signed($entire-buffer-s);

Or that decode the value from a specified offset in a given buffer, and use
an `rw` parameter of type `int`, which is incremented by the number of bytes
consumed.

    my int $read;
    my $value = decode-leb128-unsigned($buffer, $offset, $read);

To have the offset updated, it may be passed as both parameters:

    my $value = decode-leb128-unsigned($buffer, $offset, $offset);
