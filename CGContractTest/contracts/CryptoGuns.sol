// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./safemath32.sol";
import "./ERC20Interface.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
//import "./VRFConsumerBaseUpgradeable.sol";


contract CryptoGuns is ERC721Upgradeable, AccessControlUpgradeable, ERC721URIStorageUpgradeable{
  using AddressUpgradeable for address;
  using SafeMath32 for uint32;
  using SafeMath16 for uint16;

  struct Swat {
    string name;
    string rarity;
    bool upgraded;
    uint32 readyTime;
  }

//Events
event NewSwat(address indexed _player, uint _swatId, string _name);
event Burn(address indexed _player, uint256 _swatId);
event SwatPriceSet(uint newPrice);
event NewSpecificSwat(address indexed _receivingPlayer, string _name, string _rarity);
event Purchased(address indexed _receivingPlayer);
event TokenWithdrawal(uint _amount);


//Mappings
mapping(address => uint[]) public userOwnedSwats; //tokenID of swat units in wallet
mapping(uint => uint) public swatIsAtIndex; // index of the tokenID in the wallet
mapping (address => uint) public ownerSwatCount; //# of swat units in wallet
//VRF MAPPINGS
//mapping(bytes32 => address) requestToSender;
//mapping(bytes32 => uint256) requestToTokenId;

// Access Control Roles
bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

//Variables
Swat[] public swats;

//VRF VARIABLES
//bytes32 internal keyHash;
//uint256 internal fee;
//uint256 public roll;
//address public VRFCoordinator;
// bsc testnet: 0xa555fC018435bef5A13C6c6870a9d4C11DEC329C
//address public LinkToken;
// bsc testnet: 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06
uint public swatPrice; // in banana
uint public cooldownTime;
uint nonce;
ERC20Interface public acceptedToken;
address public _acceptedToken;

 //VRF FUNCTION
 // /**
 //     * initialize inherits VRFConsumerBase
 //     *
 //     * Network: Binance Smart Chain Testnet
 //     * Chainlink VRF Coordinator address: 0xa555fC018435bef5A13C6c6870a9d4C11DEC329C
 //     * LINK token address:                0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06
 //     * Key Hash: 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186
 //     */
function initialize() public initializer {
  // VRF PARAMs address _VRFCoordinator, address _LinkToken,  bytes32 _keyhash
     __ERC721_init("CryptoGuns Squad Members", "SquadMembers");
     __AccessControl_init();
     __ERC721URIStorage_init();
     // __VRFConsumerBase_init(_VRFCoordinator, _LinkToken);
     _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
     _setupRole(MINTER_ROLE, _msgSender());
     _setupRole(BURNER_ROLE, _msgSender());
         // for mainnet address bananaAdress = 0x603c7f932ed1fc6575303d8fb018fdcbb0f39a95;
         // we made a test simple bep20token for testnet.
     _acceptedToken = 0x603c7f932ED1fc6575303D8Fb018fDCBb0f39a95;

      cooldownTime = 1 days;
      nonce = 0;
      acceptedToken = ERC20Interface(_acceptedToken);

      // VRFCoordinator = _VRFCoordinator;
      //  LinkToken = _LinkToken;
      //  keyHash = _keyhash;
      // fee = 0.1 * 10**18; // 0.1 LINK
}
  function _baseURI() internal pure override returns (string memory) {
    return "https://www.cryptoguns.io/json/";
  }

function addAdmin(address account) public virtual {
  require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Must have admin role to perform this operation");
  grantRole(DEFAULT_ADMIN_ROLE, account);
 }
 function addMinter(address account) public virtual {
   require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Must have admin role to perform this operation");
   grantRole(MINTER_ROLE, account);
  }


 //VRF FUNCTIONS
 //**
 //    * Requests randomness
 //    */
 //   function getRandomNumber() public returns (bytes32 requestId) {
 //       require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
 //       requestId = requestRandomness(keyHash, fee);
 //       requestToSender[requestId] = msg.sender;
 //       return requestRandomness(keyHash, fee);
 //   }



   // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract

//assigns URI to swat based on name & rarity. Unity Engine reads the URI to pull character attributes for in-game stats.
  function _mintSwat(string memory _name, string memory _rarity, address _owner) internal {

    swats.push(Swat(_name, _rarity, false, uint32(block.timestamp + cooldownTime)));
    uint id = swats.length - 1;
    ownerSwatCount[_msgSender()] = ownerSwatCount[_msgSender()] + 1;
    userOwnedSwats[_msgSender()].push(id);
    uint ownedSwatLength = userOwnedSwats[_msgSender()].length;
    swatIsAtIndex[id] = ownedSwatLength -1;
    _safeMint(_owner, id);
    emit NewSwat( _owner, id, _name);
    //bytes32 rarity = keccak256(abi.encodePacked(_rarity));
    bytes32 swatName = keccak256(abi.encodePacked(_name));
    if(swatName == keccak256("jason")){
      _setTokenURI(id, _name);
    }
      else if(swatName == keccak256("discipliner")){
      _setTokenURI(id,_name);
    }
      else if(swatName == keccak256("nightmare")){
      _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("sarge")){
         _setTokenURI(id, _name);
       }
       else if(swatName == keccak256("mastersee")){
         _setTokenURI(id, _name);
       }
       else if(swatName == keccak256("loki")){
         _setTokenURI(id, _name);
       }
          else if(swatName == keccak256("jaguar")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("pistolpete.")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("freya")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("eagleeye")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("rumple")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("terrorrick")){
      _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("pump")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("action")){
        _setTokenURI(id, _name);
      }
        else if(swatName == keccak256("jimrimbo")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("keithurban")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("steve")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("woodsie")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("phil")){
        _setTokenURI(id, _name);
      }
      else if(swatName == keccak256("basicbob")){
        _setTokenURI(id, _name);
     }
    }

  function _randomRoll() internal returns (uint) {
    uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, _msgSender(), nonce))) % 1000;
    nonce++;
    return randomnumber;
  }
//
// VRF Function
// function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
//     roll = (randomness % 1000) + 1;
  function mintRandomSwat(address _owner) internal {
    string memory randName;
    string memory randRarity;
 require(_msgSender() == _owner, "A player can only mint to their own wallet.");
    // .2% for mythic, .7% for legendary, 10% for rare, 35% uncommon, rest Common
    uint roll = _randomRoll();
    if(roll >= 998) {
      randName = "jasonlake";
      randRarity = "mythic";}
    else if(roll >= 996)
      {randName = "discipliner";
      randRarity = "mythic";}
    else if(roll > 994)
      {randName = "nightmare";
      randRarity = "mythic";}

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

//for promotions/giveaways/in-game rewards
function mintSpecificSwat(address _owner, string memory _name, string memory _rarity) public{
  require(hasRole(MINTER_ROLE, _msgSender()), "User does not have Admin Role");
 _mintSwat(_name, _rarity, _owner);
 emit NewSpecificSwat(_owner, _name, _rarity);
}


//if owner has duplicates, can burn one to turn the first into "upgraded"
function duplicateUpgrade(uint _swatId, uint _targetId) public{
   require(_exists(_swatId), "TokenId does not exist");
   require(_exists(_targetId), "TokenId does not exist");
   require(ownerOf(_swatId) == _msgSender(), "You must own the character you are trying to upgrade");
   require(ownerOf(_targetId) == _msgSender(), "You must own the character you are trying to upgrade with");
  Swat storage mySwat = swats[_swatId];
  require(mySwat.upgraded == false, "Your character is already upgraded");
  mySwat.upgraded = true;
  _burn(_targetId);
  emit Burn(_msgSender(), _targetId);
  _triggerCooldown(mySwat);

}



//overrides duplicate functions begins here
  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, AccessControlUpgradeable) returns (bool) {
          return super.supportsInterface(interfaceId);

        }

  function  _burn(uint256 tokenId) internal virtual override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {

          // uint256 index = swatIsAtIndex[_targetId];
          // ownerSwatCount[_msgSender()] = ownerSwatCount[_msgSender()] - 1;
          //delete userOwnedSwats[msg.sender][index];
          return super._burn(tokenId);
  }


  function tokenURI(uint256 tokenId) public view virtual override (ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory) {
          return super.tokenURI(tokenId);
  }

// getters/setters
  function getSwatName(uint _swatId) public view returns (string memory) {
    return swats[_swatId].name;
  }


  function getRarity(uint _swatId) public view returns (string memory) {
    return swats[_swatId].rarity;
  }

  function getReadyTime(uint _swatId) public view returns (uint) {
    return swats[_swatId].readyTime;
  }

  function getUpgraded(uint _swatId) public view returns (bool) {
    return swats[_swatId].upgraded;
  }


  function _triggerCooldown(Swat storage _swat) internal {
    _swat.readyTime = uint32(block.timestamp + cooldownTime);
  }

  function _isReady(Swat memory _swat) public view returns (bool) {
      return (_swat.readyTime <= block.timestamp);
  }

//  BuyNFT Functions
//Use Approve function on token on front-end UI before running this.
  function buyNFT(address _buyer) public {
    require(_msgSender() == _buyer, "A player can only buy characters for their own wallet");
     require(acceptedToken.transferFrom(_msgSender(), address(this), swatPrice), "Transferring the sale amount failed");
         mintRandomSwat(_buyer);
         emit Purchased(_buyer);
      }


     function setSwatPrice(uint256 _price) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "User does not have Admin Role");
       require(_price > 1, "Price can not less than 1");
       require(_price != 20, "Price can not be more than 20s");
       swatPrice = _price;
     }

     function getSwatPrice() public view returns (uint256) {
         return swatPrice;
     }

     function setAcceptedToken(address newAcceptedToken) public {
       require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Must have admin role to perform this operation");
       require(newAcceptedToken.isContract(), "The accepted token address must be a deployed contract");
         _acceptedToken = newAcceptedToken;
     }

     function withdrawToken (uint _amount) external{
     require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Must have admin role to perform this operation");
     require(acceptedToken.approve(_msgSender(), _amount), "Approval Declined");
     require(acceptedToken.transferFrom(address(this), _msgSender(), _amount), "Transferring the desire amount failed");
     emit TokenWithdrawal(_amount);
     }
}
