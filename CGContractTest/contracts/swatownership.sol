pragma solidity >=0.5.0 <0.6.0;

import "./swatattack.sol";
import "./erc721.sol";
import "./safemath.sol";

contract SwatOwnership is SwatAttack, ERC721 {

  using SafeMath for uint256;

  mapping (uint => address) swatApprovals;

  function balanceOf(address _owner) external view returns (uint256) {
    return ownerSwatCount[_owner];
  }

  function ownerOf(uint256 _tokenId) external view returns (address) {
    return swatToOwner[_tokenId];
  }

  function _transfer(address _from, address _to, uint256 _tokenId) private {
    ownerSwatCount[_to] = ownerSwatCount[_to].add(1);
    ownerSwatCount[msg.sender] = ownerSwatCount[msg.sender].sub(1);
    swatToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
      require (swatToOwner[_tokenId] == msg.sender || swatApprovals[_tokenId] == msg.sender);
      _transfer(_from, _to, _tokenId);
    }

  function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
      swatApprovals[_tokenId] = _approved;
      emit Approval(msg.sender, _approved, _tokenId);
    }

}
