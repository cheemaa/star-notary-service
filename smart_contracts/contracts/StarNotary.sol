pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 { 

    struct Coordinators {
        bytes7 Dec;
        bytes7 Mag;
        bytes7 Cent;
    }

    struct Star { 
        string name;
        string story;
        Coordinators coordinates;
    }

    mapping(uint256 => Star) public tokenIdToStarInfo; 
    mapping(uint256 => uint256) public starsForSale;
    mapping(bytes7 => mapping(bytes7 => mapping(bytes7 => bool))) public isStarRegistered;

    function createStar(string _name, string _story, bytes7 _dec, bytes7 _mag, bytes7 _cent, uint256 _tokenId) public {
        require(!checkIfStarExist(_dec, _mag, _cent), "Star already registered");
        Coordinators memory coordinates = Coordinators(_dec, _mag, _cent);
        Star memory newStar = Star(_name, _story, coordinates);

        tokenIdToStarInfo[_tokenId] = newStar;
        isStarRegistered[_dec][_mag][_cent] = true;

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

    function checkIfStarExist(bytes7 _dec, bytes7 _mag, bytes7 _cent) public view returns (bool) {
        return isStarRegistered[_dec][_mag][_cent];
    }
    
    /*function mint(address _minter, uint256 _tokenId) public {
        require(tokenToOwner[_tokenId] == address(0), "this token belongs to someone else already");

        tokenToOwner[_tokenId] = _minter; 
        ownerToBalance[_minter] += 1;

        emit Transfer(address(0), _minter, _tokenId);
    }
    
    function approve() {

    }

    function safeTransferFrom() {

    }

    function SetApprovalForAll() {

    }
    
    function getApproved() {

    }
    
    function isApprovedForAll() {

    }
    
    function ownerOf(uint256 _tokenId) public view {
        return ownerOf(_tokenId);
    }
    
    /*function starsForSale() {

    }*/
    
    function tokenIdToStarInfo(uint256 _tokenId) public view returns (string starName, string starStory) {
        Star memory star = tokenIdToStarInfo[_tokenId];
        starName = star.name;
        starStory = star.story;
    }
}