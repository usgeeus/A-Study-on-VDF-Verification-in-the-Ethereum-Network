// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
import "./PietrzakLibrary.sol";

contract Pietrzak {
    function verifyPietrzak(
        BigNumber[] memory v,
        BigNumber memory x,
        BigNumber memory y,
        BigNumber memory n,
        uint256 T
    ) external view returns (bool) {
        return PietrzakLibrary.verify(v, x, y, n, T);
    }
}
