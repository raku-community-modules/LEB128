use LEB128;
use Test;

subtest 'Unsigned decoding' => {
    is-deeply decode-leb128-unsigned(Buf.new(0x00)), 0,
            'Correct decoding of 0';

    is-deeply decode-leb128-unsigned(Buf.new(0xE5, 0x8E, 0x26)), 624485,
            'Correct decoding of 624485';

    my $buffer = Buf.new(0x03, 0xE5, 0x8E, 0x26, 0xFF, 0x00);
    my int $read = 0;
    my int $offset = 1;
    is-deeply decode-leb128-unsigned($buffer, $offset, $read),
            624485,
            'Correct decoding of 624485 from inside a bigger buffer';
    is $read, 3, 'Correct number of bytes read from the buffer';
}

subtest 'Signed decoding' => {
    is-deeply decode-leb128-signed(Buf.new(0x00)), 0,
            'Correct decoding of 0';

    is-deeply decode-leb128-signed(Buf.new(0xC0, 0xBB, 0x78)), -123456,
            'Correct decoding of -123456';

    my $buffer = Buf.new(0x03, 0xE5, 0xC0, 0xBB, 0x78, 0xFF, 0x00);
    my int $read = 0;
    my int $offset = 2;
    is-deeply decode-leb128-signed($buffer, $offset, $read),
            -123456,
            'Correct decoding of -123456 from inside a bigger buffer';
    is $read, 3, 'Correct number of bytes read from the buffer';
}

done-testing;
