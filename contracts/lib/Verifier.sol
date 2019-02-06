pragma solidity 0.5.0;
pragma experimental ABIEncoderV2;

import "./Types.sol";


contract Verifier is Types {

  bytes constant internal EIP191_HEADER = "\x19\x01";
  bytes constant internal DOMAIN_NAME = "AIRSWAP";
  bytes constant internal DOMAIN_VERSION = "2";

  bytes32 private domainSeparator;

  constructor() public Types() {
    domainSeparator = keccak256(abi.encode(
        DOMAIN_TYPEHASH,
        keccak256(DOMAIN_NAME),
        keccak256(DOMAIN_VERSION),
        this
    ));
  }

  function hashParty(Party memory party) public pure returns (bytes32) {
    return keccak256(abi.encode(
        PARTY_TYPEHASH,
        party.wallet,
        party.token,
        party.param
    ));
  }

  function hashOrder(Order memory order) public view returns (bytes32) {
    return keccak256(abi.encodePacked(
        EIP191_HEADER,
        domainSeparator,
        keccak256(abi.encode(
            ORDER_TYPEHASH,
            order.expiration,
            order.nonce,
            order.sender,
            hashParty(order.maker),
            hashParty(order.taker),
            hashParty(order.partner)
        ))
    ));
  }

  function verify(Order memory order, Signature memory signature) public view returns (bool) {
    if (signature.prefixed) {
      return order.maker.wallet == ecrecover(
          keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashOrder(order))),
          signature.v, signature.r, signature.s
      );
    } else {
      return order.maker.wallet == ecrecover(
          hashOrder(order),
          signature.v, signature.r, signature.s
      );
    }
  }
}
