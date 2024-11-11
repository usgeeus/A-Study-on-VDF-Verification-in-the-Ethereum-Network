// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./BigNumbers.sol";

library PietrzakLibrary {
    function verify(
        BigNumber[] memory v,
        BigNumber memory x,
        BigNumber memory y,
        BigNumber memory n,
        uint256 T
    ) internal view returns (bool) {
        uint256 i;
        uint256 tau = log2(T);
        BigNumber memory _two = BigNumber(
            BigNumbers.BYTESTWO,
            BigNumbers.UINTTWO
        );
        do {
            BigNumber memory _r = hash128(x.val, y.val, v[i].val);
            x = BigNumbers.modmul(BigNumbers.modexp(x, _r, n), v[i], n);
            if (T & 1 != 0) y = BigNumbers.modexp(y, _two, n);
            y = BigNumbers.modmul(BigNumbers.modexp(v[i], _r, n), y, n);
            unchecked {
                ++i;
                T = T >> 1;
            }
        } while (i < tau);
        if (!BigNumbers.eq(y, BigNumbers.modexp(x, _two, n))) return false;
        return true;
    }

    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        uint256 exp;
        unchecked {
            exp = 128 * toUint(value > (1 << 128) - 1);
            value >>= exp;
            result += exp;

            exp = 64 * toUint(value > (1 << 64) - 1);
            value >>= exp;
            result += exp;

            exp = 32 * toUint(value > (1 << 32) - 1);
            value >>= exp;
            result += exp;

            exp = 16 * toUint(value > (1 << 16) - 1);
            value >>= exp;
            result += exp;

            exp = 8 * toUint(value > (1 << 8) - 1);
            value >>= exp;
            result += exp;

            exp = 4 * toUint(value > (1 << 4) - 1);
            value >>= exp;
            result += exp;

            exp = 2 * toUint(value > (1 << 2) - 1);
            value >>= exp;
            result += exp;

            result += toUint(value > 1);
        }
        return result;
    }

    function toUint(bool b) internal pure returns (uint256 u) {
        /// @solidity memory-safe-assembly
        assembly {
            u := iszero(iszero(b))
        }
    }

    function hash128(
        bytes memory a,
        bytes memory b,
        bytes memory c
    ) internal pure returns (BigNumber memory) {
        return
            BigNumbers.init(
                abi.encodePacked(keccak256(bytes.concat(a, b, c)) >> 128)
            );
    }
}
