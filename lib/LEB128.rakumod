=begin pod

=head1 NAME

LEB128 - Encoding and decoding of integers in the LEB128 encoding

=head1 SYNOPSIS

=begin code :lang<raku>

use LEB128;

my $buf-eu = encode-leb128-unsigned(1234);
my $buf-es = encode-leb128-signed(-1234);

=end code

=head1 DESCRIPTION

L<LEB128 or Little Endian Base 128|https://en.wikipedia.org/wiki/LEB128>
is a variable-length encoding of integers - that is, it aims to store
integers of different sizes efficiently. It is used in the DWARF debug
information format, Web Assembly, and other formats and protocols. This
Raku module provides both encoding and decoding.

=head1 Encoding

There are both signed and unsigned encoding functions,
C<encode-leb128-signed> and C<encode-leb128-unsigned> respectively. Both
are C<multi>s with candidates that take an C<Int> and return a C<Buf>
with the encoded value:

=begin code :lang<raku>

my $buf-eu = encode-leb128-unsigned(1234);
my $buf-es = encode-leb128-signed(-1234);

=end code

Or to write the encoded C<Int> into a C<Buf> and return the number of
bytes written, which is often more efficient since it avoids the
creation of a temporary C<Buf>:

=begin code :lang<raku>

my $buf = Buf.new;
my $offset = 0;
$offset += encode-leb128-unsigned(1234, $buf, $offset);

=end code

=head1 Decoding

There are both signed and unsigned decoding functions,
C<decode-leb128-signed> and C<decode-leb128-unsigned> respectively.
Both are C<multi>s with candidates that take a C<Buf> and try to
decode an C<Int> from the start of it, returning that C<Int>:

=begin code :lang<raku>

my $value-du = decode-leb128-unsigned($entire-buffer-u);
my $value-ds = decode-leb128-signed($entire-buffer-s);

=end code

Or that decode the value from a specified offset in a given buffer,
and use an C<rw> parameter of type C<int>, which is incremented by
the number of bytes consumed.

=begin code :lang<raku>

my int $read;
my $value = decode-leb128-unsigned($buffer, $offset, $read);

=end code

To have the offset updated, it may be passed as both parameters:

=begin code :lang<raku>

my $value = decode-leb128-unsigned($buffer, $offset, $offset);

=end code

=head1 Method reference

=end pod

#| Encodes the provided signed value into the target buffer at the
#| given offset, returning the number of bytes produced.
multi sub encode-leb128-signed(Int $value is copy, Buf $target, int $offset = 0 --> int) is export {
    my int $cur-offset = $offset;
    my Bool $more;
    repeat while $more {
        my uint $byte = $value +& 0b0111_1111;
        $value +>= 7;
        $more = not (($value == 0 && $byte +& 0x40 == 0) ||
                 ($value == -1 && $byte +& 0x40 != 0));
        $byte +|= 0b1000_0000 if $more;
        $target[$cur-offset++] = $byte;
    }
    $cur-offset - $offset
}

#| Encodes the provided signed value into a C<Buf> and returns it.
multi sub encode-leb128-signed(Int $value --> Buf) is export {
    my $result = Buf.new;
    encode-leb128-signed($value, $result);
    $result
}

#| Encodes the provided unsigned value into the target buffer at the
##| given offset, returning the number of bytes produced.
multi sub encode-leb128-unsigned(Int $value is copy, Buf $target, int $offset = 0 --> int) is export {
    my int $cur-offset = $offset;
    repeat while $value {
        my uint $byte = $value +& 0b0111_1111;
        $value +>= 7;
        $byte +|= 0b1000_0000 if $value;
        $target[$cur-offset++] = $byte;
    };
    $cur-offset - $offset
}

#| Encodes the provided unsigned value into a C<Buf> and returns it.
multi sub encode-leb128-unsigned(Int $value --> Buf) is export {
    my $result = Buf.new;
    encode-leb128-unsigned($value, $result);
    $result
}

#| This exception is thrown if LEB128 decoding fails due to there being an
#| incomplete value at the end of the buffer.
class X::LEB128::Incomplete is Exception {
    method message() {
        "LEB128 decoding failed; reached end of buffer without reading a complete value"
    }
}

#| Decodes an unsigned value from the provided buffer starting at the
#| specified offset. The final rw parameter is incremented for each
#| byte consumed from the buffer. Throws X::LEB128::Incomplete if a
#| complete value cannot be read.
multi sub decode-leb128-unsigned(Buf $encoded, int $offset is copy, int $read is rw) is export {
    my int $limit = $encoded.elems;
    my Int $result = 0;
    my uint $shift = 0;
    loop {
        die X::LEB128::Incomplete.new if $offset >= $limit;
        my uint $byte = $encoded[$offset++];
        $read++;
        $result +|= ($byte +& 0b0111_1111) +< $shift;
        last unless $byte +& 0b1000_0000;
        $shift += 7;
    }
    $result
}

#| Decodes the provided C<Buf> and returns the resulting unsigned value.
#| Throws X::LEB128::Incomplete if a complete value cannot be read.
multi sub decode-leb128-unsigned(Buf $encoded --> Int) is export {
    my int $throwaway = 0;
    my int $offset = 0;
    decode-leb128-unsigned($encoded, $offset, $throwaway)
}

#| Decodes a signed value from the provided buffer starting at the
#| specified offset. The final rw parameter is incremented for each
#| byte consumed from the buffer. Throws X::LEB128::Incomplete if a
#| complete value cannot be read.
multi sub decode-leb128-signed(Buf $encoded, int $offset is copy, int $read is rw) is export {
    my int $limit = $encoded.elems;
    my Int $result = 0;
    my uint $shift = 0;
    loop {
        die X::LEB128::Incomplete.new if $offset >= $limit;
        my uint $byte = $encoded[$offset++];
        $read++;
        $result +|= ($byte +& 0b0111_1111) +< $shift;
        $shift += 7;
        unless $byte +& 0b1000_0000 {
            if $byte +& 0x40 != 0 {
                $result +|= -1 +< $shift;
            }
            last;
      }
    }
    $result
}

#| Decodes the provided C<Buf> and returns the resulting signed value.
#| Throws X::LEB128::Incomplete if a complete value cannot be read.
multi sub decode-leb128-signed(Buf $encoded --> Int) is export {
    my int $throwaway = 0;
    my int $offset = 0;
    decode-leb128-signed($encoded, $offset, $throwaway)
}

=begin pod

=head1 AUTHOR

Jonathan Worthington

=head1 COPYRIGHT AND LICENSE

Copyright 2020 - 2024 Jonathan Worthington

Copyright 2024 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
