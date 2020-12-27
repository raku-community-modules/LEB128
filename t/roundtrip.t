use LEB128;
use Test;

for 0, 1, 7, 8, 127, 128, 255, 256, 32767, 32768, 2 ** 10 {
    subtest "Roundtrip of $_" => {
        is-deeply decode-leb128-unsigned(encode-leb128-unsigned($_)), $_,
                'Unsigned encoding roundtrips';
        is-deeply decode-leb128-signed(encode-leb128-signed($_)), $_,
                'Signed encoding roundtrips';
    }
}

for -1, -7, -8, -127, -128, -255, -256, -32767, -32768, -(2 ** 10) {
    subtest "Roundtrip of $_" => {
        is-deeply decode-leb128-signed(encode-leb128-signed($_)), $_,
                'Signed encoding roundtrips';
    }
}

done-testing;
