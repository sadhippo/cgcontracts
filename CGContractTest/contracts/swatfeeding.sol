pragma solidity >=0.5.0 <0.6.0;

import "./swatfactory.sol";

contract KittyInterface {
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

contract SwatFeeding is SwatFactory {

  KittyInterface kittyContract;

  modifier onlyOwnerOf(uint _swatId) {
    require(msg.sender == swatToOwner[_swatId]);
    _;
  }

  function setKittyContractAddress(address _address) external onlyOwner {
    kittyContract = KittyInterface(_address);
  }

  function _triggerCooldown(Swat storage _swat) internal {
    _swat.readyTime = uint32(now + cooldownTime);
  }

  function _isReady(Swat storage _swat) internal view returns (bool) {
      return (_swat.readyTime <= now);
  }

  function feedAndMultiply(uint _swatId, uint _targetDna, string memory _species) internal onlyOwnerOf(_swatId) {
    Swat storage mySwat = swats[_swatId];
    require(_isReady(mySwat));
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (mySwat.dna + _targetDna) / 2;
    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99;
    }
    _createSwat("NoName", newDna);
    _triggerCooldown(mySwat);
  }

  function feedOnKitty(uint _swatId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_swatId, kittyDna, "kitty");
  }
}
