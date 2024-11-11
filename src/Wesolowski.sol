// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./WesolowskiLibrary.sol";

contract Wesolowski {
    function verifyWesolowski(
        BigNumber memory x,
        BigNumber memory n,
        BigNumber memory T,
        BigNumber memory pi,
        BigNumber memory l
    ) external view returns (bool) {
        WesolowskiLibrary.verify(x, n, T, pi, l);
        return true;
    }
}
