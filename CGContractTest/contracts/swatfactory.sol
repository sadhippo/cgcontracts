pragma solidity >=0.5.0 <0.6.0;

import "./ownable.sol";
import "./safemath.sol";

contract SwatFactory is Ownable {

  using SafeMath for uint256;
  using SafeMath32 for uint32;
  using SafeMath16 for uint16;

  event NewSwat(uint  swatId, string name, uint dna);

  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;
  uint cooldownTime = 1 days;

  struct Swat {
    string name;
    uint dna;
    uint32 level;
    uint32 readyTime;
    uint16 winCount;
    uint16 lossCount;
  }

  Swat[] public swats;

  mapping (uint => address) public swatToOwner;
  mapping (address => uint) ownerSwatCount;

  function _createSwat(string memory _name, uint _dna) internal {
    uint id = swats.push(Swat(_name, _dna, 1, uint32(now + cooldownTime), 0, 0)) - 1;
    swatToOwner[id] = msg.sender;
    ownerSwatCount[msg.sender] = ownerSwatCount[msg.sender].add(1);
    emit NewSwat(id, _name, _dna);
  }

  function _generateRandomDna(string memory _str) private view returns (uint) {
    uint rand = uint(keccak256(abi.encodePacked(_str)));
    return rand % dnaModulus;
  }

  function createRandomSwat(string memory _name) public {
    require(ownerSwatCount[msg.sender] < 4);
    uint randDna = _generateRandomDna(_name);
    randDna = randDna - randDna % 100;
    _createSwat(_name, randDna);
  }
}
