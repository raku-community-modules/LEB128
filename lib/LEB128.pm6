#| Encodes the provided signed value into the target buffer at the
#| given offset, returning the number of bytes produced.
multi sub encode-leb128-signed(Int $value is copy, Buf $target, int $offset = 0 --> int) is export {
    my int $cur-offset = $offset;
    my Bool $more;
    repeat while $more {
        my int $byte = $value +& 0b0111_1111;
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
        my int $byte = $value +& 0b0111_1111;
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
    my int $shift = 0;
    loop {
        die X::LEB128::Incomplete.new if $offset >= $limit;
        my int $byte = $encoded[$offset++];
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
    my int $shift = 0;
    loop {
        die X::LEB128::Incomplete.new if $offset >= $limit;
        my int $byte = $encoded[$offset++];
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