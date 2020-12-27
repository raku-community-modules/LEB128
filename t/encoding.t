use LEB128;
use Test;

subtest 'Unsigned encoding' => {
    is-deeply encode-leb128-unsigned(0), Buf.new(0x00),
            'Correct encoding of 0';

    is-deeply encode-leb128-unsigned(624485), Buf.new(0xE5, 0x8E, 0x26),
            'Correct encoding of 624485';

    my $buf = Buf.allocate(8);
    my int $offset = 3;
    is encode-leb128-unsigned(624485, $buf, $offset), 3,
            'Encode into buffer returns number of bytes written';
    is-deeply $buf, Buf.new(0, 0, 0, 0xE5, 0x8E, 0x26, 0, 0),
            'Encoded into buffer at specified offset';
}

subtest 'Signed encoding' => {
    is-deeply encode-leb128-signed(0), Buf.new(0x00),
            'Correct encoding of 0';

    is-deeply encode-leb128-signed(-123456), Buf.new(0xC0, 0xBB, 0x78),
            'Correct encoding of -123456';

    my $buf = Buf.allocate(8);
    my int $offset = 2;
    is encode-leb128-signed(-123456, $buf, $offset), 3,
            'Encode into buffer returns number of bytes written';
    is-deeply $buf, Buf.new(0, 0, 0xC0, 0xBB, 0x78, 0, 0, 0),
            'Encoded into buffer at specified offset';
}

done-testing;
