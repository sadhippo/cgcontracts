pragma solidity >=0.5.0 <0.6.0;

import "./swathelper.sol";

contract SwatAttack is SwatHelper {
  uint randNonce = 0;
  uint attackVictoryProbability = 70;

  function randMod(uint _modulus) internal returns(uint) {
    randNonce = randNonce.add(1);
    return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % _modulus;
  }
///if player wins, increase win count by 1, level by 1, enemy loss count by 1, runs feed and multiply; else player loss count goes up 1
  function attack(uint _swatId, uint _targetId) external onlyOwnerOf(_swatId) {
    Swat storage mySwat = swats[_swatId];
    Swat storage enemySwat = swats[_targetId];
    uint rand = randMod(100);
    if (rand <= attackVictoryProbability) {
      mySwat.winCount = mySwat.winCount.add(1);
      mySwat.level = mySwat.level.add(1);
      enemySwat.lossCount = enemySwat.lossCount.add(1);
      feedAndMultiply(_swatId, enemySwat.dna, "swat");
    } else {
      mySwat.lossCount = mySwat.lossCount.add(1);
      enemySwat.winCount = enemySwat.winCount.add(1);
      _triggerCooldown(mySwat);
    }
  }
}
