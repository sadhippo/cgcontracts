// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./safemath32.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

contract CryptoGuns is ERC721Upgradeable, OwnableUpgradeable, AccessControlUpgradeable, ERC721URIStorageUpgradeable  {
  using AddressUpgradeable for address;
  using SafeMath32 for uint32;
  using SafeMath16 for uint16;

  event NewSwat(uint swatId, string name, string rarity);
    event Purchased(address buyer);

  struct Swat {
    string name;
    string rarity;
    uint32 level;
    bool upgraded;
    uint32 readyTime;
  }


  Swat[] public swats;
address  public _acceptedToken; //banana
  uint swatPrice; // in banana
    uint cooldownTime;
    uint tokenPrice; //banana price
    // for mainnet address bananaAdress = 0x603c7f932ed1fc6575303d8fb018fdcbb0f39a95;

  //mappings
  mapping (uint => address) public swatToOwner; //takes swatID and gives owner address
  mapping (address => uint) public ownerSwatCount; //# of swat units in wallet
  mapping(address => uint[]) public userOwnedSwats; //tokenID of swat units in wallet
  mapping(uint => uint) public swatIsAtIndex; // index of the tokenID in the wallet
  mapping (uint256 => uint256) private _tokenPrice;

  modifier aboveLevel(uint _level, uint _swatId) {
    require(swats[_swatId].level >= _level);
    _;
  }


  function initialize() public initializer {
     __ERC721_init("CryptoGuns Squad Members", "SquadMembers");
     __AccessControl_init();
     __Ownable_init();
     __ERC721URIStorage_init();

     _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());


      cooldownTime = 1 days;



  }
//assigns URI to swat based on name & rarity. Unity Engine reads the URI to pull character attributes for in-game stats.
  function _mintSwat(string memory _name, string memory _rarity, address _owner) internal {
    swats.push(Swat(_name, _rarity, 1, false, uint32(block.timestamp + cooldownTime)));
    uint id = swats.length - 1;
    ownerSwatCount[msg.sender] = ownerSwatCount[msg.sender] + 1;
    userOwnedSwats[msg.sender].push(id);
    uint ownedSwatLength = userOwnedSwats[msg.sender].length;
    swatIsAtIndex[id] = ownedSwatLength;
    _safeMint(_owner, id);
    emit NewSwat(id, _name, _rarity);
    //bytes32 rarity = keccak256(abi.encodePacked(_rarity));
    bytes32 swatName = keccak256(abi.encodePacked(_name));
    if(swatName == keccak256("jason")){
      _setTokenURI(id,"https://www.cryptoguns.io/json/jason");
    }
      else if(swatName == keccak256("discipliner")){
      _setTokenURI(id,"https://www.cryptoguns.io/json/discipliner");
    }
      else if(swatName == keccak256("nightmare")){
      _setTokenURI(id,"https://www.cryptoguns.io/json/nightmare");
      }
      else if(swatName == keccak256("sarge")){
         _setTokenURI(id,"https://www.cryptoguns.io/json/sarge");
       }
       else if(swatName == keccak256("mastersee")){
         _setTokenURI(id,"https://www.cryptoguns.io/json/mastersee");
       }
       else if(swatName == keccak256("loki")){
         _setTokenURI(id,"https://www.cryptoguns.io/json/loki");
       }
          else if(swatName == keccak256("jaguar")){
        _setTokenURI(id,"https://www.cryptoguns.io/json/jaguar");
      }
      else if(swatName == keccak256("pistolpete.")){
        _setTokenURI(id,"https://www.cryptoguns.io/json/pistolpete");
      }
      else if(swatName == keccak256("freya")){
        _setTokenURI(id,"https://www.cryptoguns.io/json/freya");
      }
      else if(swatName == keccak256("eagleeye")){
        _setTokenURI(id,"https://www.cryptoguns.io/json/eagleeye");
      }
      else if(swatName == keccak256("rumple")){
        _setTokenURI(id,"https://www.cryptoguns.io/json/rumple");
      }
      else if(swatName == keccak256("terrorrick")){
      _setTokenURI(id,"https://www.cryptoguns.io/json/terrorrick");
      }
      else if(swatName == keccak256("pump")){
        _setTokenURI(id,"https://www.cryptoguns.io/json/pump");
      }
      else if(swatName == keccak256("action")){
        _setTokenURI(id,"https://www.cryptoguns.io/json/action");
      }
        else if(swatName == keccak256("jimrimbo")){
        _setTokenURI(id,"https://www.cryptoguns.io/json/jimrimbo");
      }
      else if(swatName == keccak256("keithurban")){
        _setTokenURI(id,"https://www.cryptoguns.io/json/keithurban");
      }
      else if(swatName == keccak256("steve")){
        _setTokenURI(id,"https://www.cryptoguns.io/json/steve");
      }
      else if(swatName == keccak256("woodsie")){
        _setTokenURI(id,"https://www.cryptoguns.io/json/woodsie");
      }
      else if(swatName == keccak256("phil")){
        _setTokenURI(id,"https://www.cryptoguns.io/json/phil");
      }
      else if(swatName == keccak256("basicbob")){
        _setTokenURI(id,"https://www.cryptoguns.io/json/basicbob");
     }
    }

  function _rollrandom() internal view returns (uint) {
    uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 1000;
    return randomnumber;
}

//set to public for testing with Unity Engine, will set to internal on live
  function mintRandomSwat(address _owner) public {
   require(ownerSwatCount[_owner] < 4); // for testing purposes in the game engine, will be allowed unlimited swats on launch 
   require(_owner == msg.sender);
    string memory randName;
    string memory randRarity;

    // .2% for mything, .7% for legendary, 10% for rare, 35% uncommon, rest Common
    uint roll = _rollrandom();
    if(roll >= 998) {
    randName = "jason";
    randName = "mythic";
    }
    else if(roll >= 996)
    {randName = "discipliner";
    randName = "mythic";}
    else if(roll > 994)
    {randName = "nightmare";
    randName = "mythic";}

    else if(roll > 991){
    randName = "sarge";
      randRarity = "legendary";}
    else if(roll > 987){
    randName = "mastersee";
      randRarity = "legendary";}
      else if(roll > 984){
    randName = "loki";
      randRarity = "legendary";}

    else if(roll > 950){
    randName = "jaguar";
    randRarity = "rare";}
    else if(roll > 930){
    randName = "pistolpete";
    randRarity = "rare";}
    else if(roll > 910){
    randName = "freya";
    randRarity = "rare";}
    else if(roll > 890){
    randName = "eagleeye";
    randRarity = "rare";}
    else if(roll > 870){
    randName = "rumple";
    randRarity = "rare";}
      else if(roll > 850){
    randName = "terrorrick";
    randRarity = "rare"; }

      else if(roll > 750)
    {randName = "pump";
    randRarity = "Uncommon"; }
      else if(roll > 650)
    {randName = "action";
    randRarity = "Uncommon"; }
      else if(roll > 500){
    randName = "jimrimbo";
    randRarity = "Uncommon"; }

      else if(roll > 400){
    randName = "keithurban";
    randRarity = "Common"; }
      else if(roll > 300){
    randName = "steve";
    randRarity = "Common"; }
      else if(roll > 200){
    randName = "woodsie";
    randRarity = "Common"; }
      else if(roll > 100){
    randName = "phil";
    randRarity = "Common"; }
      else {
    randName = "basicbob";
    randRarity = "Common"; }
  _mintSwat(randName, randRarity, _owner);
}

//for promotions/giveaways/testing
function mintSpecificSwat(address _owner, string memory _name, string memory _rarity) public onlyOwner{
 _mintSwat(_name, _rarity, _owner);
}

function _triggerCooldown(Swat storage _swat) internal {
  _swat.readyTime = uint32(block.timestamp + cooldownTime);
}

function _isReady(Swat storage _swat) internal view returns (bool) {
    return (_swat.readyTime <= block.timestamp);
}

//if owner has duplicates, can burn one to turn the first into "upgraded"
function duplicateUpgrade(uint _swatId, uint _targetId) public{
  require(ownerOf(_swatId) == msg.sender);
  require(ownerOf(_targetId) == msg.sender);
  Swat storage mySwat = swats[_swatId];
  require(mySwat.upgraded == false);
  mySwat.upgraded = true;
  _burn(_targetId);
  _triggerCooldown(mySwat);
}

mapping (uint => address) swatApprovals;

//overrides duplicate functions begins here
  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, AccessControlUpgradeable) returns (bool) {
          return super.supportsInterface(interfaceId);

        }

  function  _burn(uint256 tokenId) internal virtual override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
          return super._burn(tokenId);
  }


  function tokenURI(uint256 tokenId) public view virtual override (ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory) {
          return super.tokenURI(tokenId);
  }
//ends

//level ups the swat
  function levelUp(uint _swatId) public payable {
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Not game admin");
    swats[_swatId].level = swats[_swatId].level + 1;
  }

  //swat properities getters
  function getLevel(uint _swatId) public view onlyOwner returns (uint) {
    return swats[_swatId].level;
  }

  function getName(uint _swatId) public view onlyOwner returns (string memory) {
    return swats[_swatId].name;
  }


  function getRarity(uint _swatId) public view onlyOwner returns (string memory) {
    return swats[_swatId].rarity;
  }

  function getReadyTime(uint _swatId) public view onlyOwner returns (uint) {
    return swats[_swatId].readyTime;
  }

  function getUpgraded(uint _swatId) public view onlyOwner returns (bool) {
    return swats[_swatId].upgraded;
  }

  //BuyNFT functions

  function setToken(address addr) public onlyOwner() {
  //  require(_acceptedToken.isContract(), "The accepted token address must be a deployed contract");
    _acceptedToken = addr;
     }

     function getTokenPrice(uint256 tokenId) public view returns (uint256) {
         return _tokenPrice[tokenId];
     }

     function setSwatPrice(uint256 _price) public onlyOwner {
       swatPrice = (tokenPrice * _price);
       //mainnet
       //swatPrice = (getTokenPrice(bananaAddress) * _price)
     }

//should require the message sender to be the buyer,  require the msg.value is greater than or equal to the swat token price, should transfer the token to the contract, should then mint a new swat unit to the msg sender.
//Testing Note* did not know how to test without having banana testnet address
     function buyNFT(address _buyer) public payable {
       require(msg.sender == _buyer);
        require(msg.sender != address(0));
        //require(_acceptedToken.balanceOf(_buyer) >= swatPrice, "You do not have enough coins in your wallet.");
        require(msg.value >= swatPrice, "You must pay the full price of the NFT");
        safeTransferFrom(msg.sender, address(this), swatPrice);
            mintRandomSwat(msg.sender);
            emit Purchased(msg.sender);
         }

}
