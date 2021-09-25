pragma solidity >=0.5.0 <0.6.0;

import "./swatfeeding.sol";

contract SwatHelper is SwatFeeding {

  uint levelUpFee = 0.001 ether;

  modifier aboveLevel(uint _level, uint _swatId) {
    require(swats[_swatId].level >= _level);
    _;
  }


  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }

  function levelUp(uint _swatId) external payable {
    require(msg.value == levelUpFee);
    swats[_swatId].level = swats[_swatId].level.add(1);
  }

  //function changeName(uint _swatId, string calldata _newName) external aboveLevel(2, _swatId) onlyOwnerOf(_swatId) {
//    swats[_swatId].name = _newName;
//  }

  function changeDna(uint _swatId, uint _newDna) external aboveLevel(20, _swatId) onlyOwnerOf(_swatId) {
    swats[_swatId].dna = _newDna;
  }

  function getSwatsByOwner(address _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ownerSwatCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < swats.length; i++) {
      if (swatToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }
}
