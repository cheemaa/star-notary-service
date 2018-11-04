pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 { 

    struct Coordinators {
        string dec;
        string mag;
        string cent;
    }

    struct Star { 
        string name;
        string story;
        Coordinators coordinates;
    }

    mapping(uint256 => Star) public tokenIdToStarInfo; 
    mapping(uint256 => uint256) public starsForSale;
    mapping(bytes32 => mapping(bytes32 => mapping(bytes32 => bool))) public isStarRegistered;

    /************************************************************************************************************/
    /******************************************* String Utils ***************************************************/
    /************************************************************************************************************/
    function bytesToBytes32(bytes b) private pure returns (bytes7) {
        bytes7 out;
        for (uint i = 0; i < 7; i++) {
            out |= bytes7(b[i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function stringToBytes32(string memory source) private constant returns (bytes32 result) {
        assembly {
        result := mload(add(source, 32))
        }
    }

    function bytes32ToString(bytes32 _bytes32) private constant returns (string){
        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    function toSlice(string self) internal returns (slice) {
        uint ptr;
        assembly {
        ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    function stringsConcatenation(string str1, string str2) private constant returns (string) {
        return concat(toSlice(str1), toSlice(str2));
    }

    function concat(slice self, slice other) internal returns (string) {
        string memory ret = new string(self._len + other._len);
        uint retptr;
        assembly {retptr := add(ret, 32)}
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }

    struct slice {uint _len; uint _ptr;}

    function memcpy(uint dest, uint src, uint len) private {
        for (; len >= 32; len -= 32) {
            assembly {
            mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }
        uint mask = 256 ** (32 - len) - 1;
        assembly {
        let srcpart := and(mload(src), not(mask))
        let destpart := and(mload(dest), mask)
        mstore(dest, or(destpart, srcpart))
        }
    }
    /************************************************************************************************************/
    /************************************************************************************************************/
    /************************************************************************************************************/

    function createStar(string _name, string _story, string _dec, string _mag, string _cent, uint256 _tokenId) public {
        require(!checkIfStarExist(_dec, _mag, _cent), "Star already registered");
        Coordinators memory coordinates = Coordinators(_dec, _mag, _cent);
        Star memory newStar = Star(_name, _story, coordinates);

        tokenIdToStarInfo[_tokenId] = newStar;
        isStarRegistered[stringToBytes32(_dec)][stringToBytes32(_mag)][stringToBytes32(_cent)] = true;

        _mint(msg.sender, _tokenId);
    }

    function putStarUpForSale(uint256 _tokenId, uint256 _price) public { 
        require(this.ownerOf(_tokenId) == msg.sender);

        starsForSale[_tokenId] = _price;
    }

    function buyStar(uint256 _tokenId) public payable { 
        require(starsForSale[_tokenId] > 0);

        uint256 starCost = starsForSale[_tokenId];
        address starOwner = this.ownerOf(_tokenId);
        require(msg.value >= starCost);

        _removeTokenFrom(starOwner, _tokenId);
        _addTokenTo(msg.sender, _tokenId);

        starOwner.transfer(starCost);

        if(msg.value > starCost) { 
            msg.sender.transfer(msg.value - starCost);
        }
    }

    function checkIfStarExist(string _dec, string _mag, string _cent) public view returns (bool) {
        return isStarRegistered[stringToBytes32(_dec)][stringToBytes32(_mag)][stringToBytes32(_cent)];
    }
    
    function starsForSale(uint256 _tokenId) public view returns(uint256) {
        return starsForSale[_tokenId];
    }
    
    function tokenIdToStarInfo(uint256 _tokenId) public view returns (string starName, string starStory,
    string ra, string dec, string mag) {
        Star memory star = tokenIdToStarInfo[_tokenId];
        starName = star.name;
        starStory = star.story;
        ra = stringsConcatenation("ra_", star.coordinates.cent);
        dec = stringsConcatenation("dec_", star.coordinates.dec);
        mag = stringsConcatenation("mag_", star.coordinates.mag);
    }
}