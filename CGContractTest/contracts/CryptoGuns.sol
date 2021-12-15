// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./safemath32.sol";
import "./ERC20Interface.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "./VRFConsumerBaseUpgradable.sol";


contract CryptoGuns is AccessControlUpgradeable, ERC721URIStorageUpgradeable, VRFConsumerBaseUpgradable{
  using SafeMath32 for uint32;
  using SafeMathUpgradeable for uint256;

  struct Swat {
    string name;
    bool upgraded;
    uint32 readyTime;
  }

//Events
event NewSwat(address indexed _player, uint _swatId, string _name);
event Burn(address indexed _player, uint256 _swatId);
event SwatPriceSet(uint newPrice);
event NewSpecificSwat(address indexed _receivingPlayer, string _name);
event Purchased(address indexed _receivingPlayer);
event TokenWithdrawal(uint _amount);
event LinkTokenWithdrawal(uint _amount);


//Mappings
mapping(address => uint[]) public userOwnedSwats; //tokenID of swat units in wallet
mapping(uint => uint) public swatIsAtIndex; // index of the tokenID in the wallet
mapping (address => uint) public ownerSwatCount; //# of swat units in wallet
//VRF MAPPINGS
mapping(bytes32 => address) requestToSender;
mapping(bytes32 => uint256) requestToTokenId;

// Access Control Roles
bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

//Variables
Swat[] public swats;

//VRF VARIABLES
bytes32 internal keyHash;
uint256 internal fee;
uint256 public roll;
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
     _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
     _setupRole(MINTER_ROLE, _msgSender());
     VRFConsumerBaseUpgradable.initialize(
            0xa555fC018435bef5A13C6c6870a9d4C11DEC329C, // VRF Coordinator
            0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06  // LINK Token
        );
         // for mainnet address bananaAdress = 0x603c7f932ed1fc6575303d8fb018fdcbb0f39a95;
         // we made a test simple bep20token for testnet. - 0x0C69F8B5133038D445d9dc9CA53a0061FE260Ea6
     _acceptedToken = 0x603c7f932ED1fc6575303D8Fb018fDCBb0f39a95;
     keyHash = 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186;
      cooldownTime = 1 days;
      nonce = 0;
      acceptedToken = ERC20Interface(_acceptedToken);
      fee = 0.1 * 10**18; // 0.1 LINK
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
 // **
 //    * Requests randomness
 //    */
   function getRandomNumber() public returns (bytes32 requestId) {
       require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
       requestId = requestRandomness(keyHash, fee);
       requestToSender[requestId] = msg.sender;
    //   return requestRandomness(keyHash, fee);
   }



    function withdrawLink(uint _amount) external { //Implement a withdraw function to avoid locking your LINK in the contract
      require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()));
      require(LINK.transfer(_msgSender(), _amount), "Transferring the desire amount failed");
      emit LinkTokenWithdrawal(_amount);

    }

//assigns URI to swat based on name. Unity Engine reads the URI to pull character attributes for in-game stats.
  function _mintSwat(string memory _name,address _owner) internal {

    swats.push(Swat(_name, false, uint32(block.timestamp + cooldownTime)));
    uint id = swats.length - 1;
    ownerSwatCount[msg.sender] = ownerSwatCount[msg.sender] + 1;
    userOwnedSwats[msg.sender].push(id);
    uint ownedSwatLength = userOwnedSwats[_msgSender()].length;
    swatIsAtIndex[id] = ownedSwatLength -1;
    _safeMint(_owner, id);
    emit NewSwat( msg.sender, id, _name);
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
      else if(swatName == keccak256("pistolpete")){
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

  // function _randomRoll() internal returns (uint) {
  //   uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, _msgSender(), nonce))) % 1000;
  //   nonce++;
  //   return randomnumber;
  // }
//
// VRF Function
// function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
//
  //function mintRandomSwat(address _owner) public {
  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    string memory randName;
     address requestAddress = requestToSender[requestId];
    // .2% for mythic, .7% for legendary, 10% for rare, 35% uncommon, rest Common
    roll = (randomness % 1000) + 1;

    if(roll >= 998) {
      randName = "jasonlake";
    }
    else if(roll >= 996)
      {randName = "discipliner";
      }
    else if(roll > 994)
      {randName = "nightmare";
      }

    else if(roll > 991){
      randName = "sarge";
    }
    else if(roll > 987){
      randName = "mastersee";
    }
    else if(roll > 984){
      randName = "loki";
  }

    else if(roll > 950){
      randName = "jaguar";
    }
    else if(roll > 930){
      randName = "pistolpete";
    }
    else if(roll > 910){
      randName = "freya";
    }
    else if(roll > 890){
      randName = "eagleeye";
    }
    else if(roll > 870){
      randName = "rumple";
      }
    else if(roll > 850){
      randName = "terrorrick";
    }

    else if(roll > 750)
      {randName = "pump";
    }
    else if(roll > 650)
      {randName = "action";
      }
    else if(roll > 500){
      randName = "jimrimbo";
      }

    else if(roll > 400){
      randName = "keithurban";
    }
    else if(roll > 300){
      randName = "steve";
     }
    else if(roll > 200){
      randName = "woodsie";
     }
    else if(roll > 100){
      randName = "phil";
   }
    else {
      randName = "basicbob";
       }
  _mintSwat(randName, requestAddress);
}


function mintSpecificSwat(address _owner, string memory _name) public{
  require(hasRole(MINTER_ROLE, _msgSender()), "User does not have Minter Role");
 _mintSwat(_name, _owner);
 emit NewSpecificSwat(_owner, _name);
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

  function  _burn(uint256 tokenId) internal virtual override(ERC721URIStorageUpgradeable) {
          uint256 index = swatIsAtIndex[tokenId];
        ownerSwatCount[msg.sender] = ownerSwatCount[msg.sender] - 1;
         delete userOwnedSwats[msg.sender][index];
         //swatIsAtIndex[tokenId] = -1;
          return super._burn(tokenId);
  }


//removes the unit from the owner's swat count. then it adds the unit to the recievers swat count and it updates the swatIndex to it's position in the recievers wallet.
// then it sets the mapping userOwnedSwats to an outrageously high number that we tell the front-end to ignore on load.
  function  _transfer(address _from, address _to, uint256 _tokenId) internal virtual override {
          require(_from == msg.sender, "You must own the unit you want to trade");
            uint256 index = swatIsAtIndex[_tokenId];
            //update mappings
          ownerSwatCount[_from] = ownerSwatCount[_from] - 1;
          ownerSwatCount[_to] = ownerSwatCount[_to] + 1;
          userOwnedSwats[_to].push(_tokenId);
          uint256 toOwnedSwatLength = userOwnedSwats[_to].length;
          swatIsAtIndex[_tokenId] = toOwnedSwatLength - 1;
          userOwnedSwats[_from][index] = 999999;

          return super._transfer(_from, _to, _tokenId);
  }
//ERC721Upgradeable
  function tokenURI(uint256 tokenId) public view virtual override (ERC721URIStorageUpgradeable) returns (string memory) {
          return super.tokenURI(tokenId);
  }

// getters/setters
  function getSwatName(uint _swatId) public view returns (string memory) {
    return swats[_swatId].name;
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

function getSwatsOwnedBy(address _owner) public view returns (uint){
  uint SwatCount = ownerSwatCount[_owner];
  return SwatCount;
}

function getSwatIndex(uint _id) public view returns (uint){
  uint SwatIndex = swatIsAtIndex[_id];
  return SwatIndex;
}

//  BuyNFT Functions
// Use Approve function on token on front-end UI before running this.
  function buyNFT(address _buyer) public {
    require(_msgSender() == _buyer, "A player can only buy characters for their own wallet");
    require(acceptedToken.transferFrom(_msgSender(), address(this), swatPrice), "Transferring the sale amount failed");
    mintRandomSwat(_buyer);

    emit Purchased(_buyer);
      }


     function setSwatPrice(uint256 _price) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "User does not have Admin Role");
       require(_price > 1 * 10**18, "Price can not less than 1");
       require(_price != 20 * 10**18, "Price can not be more than 20s");
       swatPrice = _price;

       emit SwatPriceSet(_price);
     }

     function getSwatPrice() public view returns (uint256) {
         return swatPrice;
     }


     function withdrawToken (uint _amount) external{
     require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Must have admin role to perform this operation");
     require(acceptedToken.transfer(_msgSender(), _amount), "Transferring the desire amount failed");
     emit TokenWithdrawal(_amount);
     }
}
